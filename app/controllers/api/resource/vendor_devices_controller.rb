class Api::Resource::VendorDevicesController < Api::Base
  before_action :check_params, :except => :crawl
  before_action :check_cloud_id, :except => :crawl
  before_action :check_device, :except => :crawl
  before_action :check_signature, :except => :crawl

  def index
    begin
      # cloud_id = "zyxoperator"
      # @user = User.first

      saved_vendor_devices = []

      # 由 NAS 端傳入 cloud_id
      vendor_devices = VendorDevice.where(user_id: @user.id)
      cloud_id = @user.encoded_id

      # 資料更新頻率
      data_safe_period = Settings.vendors.asi.data_safe_period.to_i

      # 假如 DB 當中找不到該 user 的 vendor devices，則呼叫 ASI 的 Get Device List API 取得 user 的 vendor devices 資料，
      # 並且儲存到 DB，並傳回 user 的 vendor_devices(JSON) 給 NAS
      if vendor_devices.blank?
        # 呼叫 ASI 的 Get Device List API 取得 user 的 vendor devices
        device_list = get_devise_list_from_vendor(cloud_id)
        # 將取回的資料存入 DB
        saved_vendor_devices = save_data_to_db(device_list, @user.id)

      else 
        # 假如 user_id 找到 vendor_devices，看每一個 vendor_device 的 update 日期是否超過十分鐘，
        # 若超過，則去打ASI的API撈資料，存到DB，再傳json給NAS
        # 若沒超過，就略過此步驟，最後再掃一次user的vendor_devices，回傳json
        if vendor_devices.any? { |vendor_device| vendor_device.updated_at < data_safe_period.minutes.ago }
          device_list = get_devise_list_from_vendor(cloud_id)
          saved_vendor_devices = save_data_to_db(device_list, @user.id)
        end
      end

      render :json => { "cloud_id" => cloud_id,
                        "device_list" => saved_vendor_devices }, status: 200

    rescue Exception => error
      logger.error(error.message)
      render :json => { error_code: "300", description: "Unexpected error." }, status: 400 if error
    end
  end

  def crawl
    begin
      saved_vendor_devices = []

      # 資料更新頻率
      data_safe_period = Settings.vendors.asi.data_safe_period.to_i

      devices_that_need_updating = VendorDevice.select(
          :user_id
        ).where.not(updated_at: data_safe_period.minutes.ago..Time.now).distinct

      logger.debug("devices_that_need_updating: #{devices_that_need_updating.to_json}")

      devices_that_need_updating.each do |vendor_device|
        cloud_id = User.find(vendor_device.user_id).encoded_id
        device_list = get_devise_list_from_vendor(cloud_id)
        saved_vendor_devices = save_data_to_db(device_list, vendor_device.user_id)
      end

      render :json => { "result" => "success",
                        "device_list" => saved_vendor_devices }, status: 200

    rescue Exception => error
      logger.error(error.message)
      render :json => { error_code: "300", description: "Unexpected error." }, status: 400 if error
    end
  end


  private

    def valid_params
      params.permit(:certificate_serial, :signature, :cloud_id, :mac_address, :serial_number)
    end

    def check_params
      if valid_params.keys != ["certificate_serial", "signature", "cloud_id", "mac_address", "serial_number"]
        return render :json => { error_code: "000", description: "Missing required params." }, status: 400
      end
      valid_params.values.each do |value|
        return render :json => { error_code: "000", description: "Missing required params." }, status: 400 if value.blank?
      end
    end

    def check_cloud_id
      @user = User.find_by_encoded_id(valid_params[:cloud_id])
      return render :json => { error_code: "201", description: "invalid cloud id or token." }, status: 400 if @user.blank?
    end

    def check_device
      device = Device.find_by(serial_number: valid_params[:serial_number], mac_address: valid_params[:mac_address])
      return render :json => { error_code: "004", description: "invalid device." }, status: 400 if device.blank?
      pairing = Pairing.where(user_id: @user.id).where(device_id: device.id)
      return render :json => { error_code: "004", description: "invalid device." }, status: 400 if pairing.blank?
    end

    def check_signature
      key = valid_params[:certificate_serial] + valid_params[:cloud_id] + valid_params[:mac_address] + valid_params[:serial_number]
      signature = valid_params[:signature]
      certificate_serial = valid_params[:certificate_serial]

      return render :json => { error_code: "101", description: "invalid signature." }, status: 400 unless validate_signature(signature, key, certificate_serial)
    end

    def validate_signature(signature, key, serial)
      sha224 = OpenSSL::Digest::SHA224.new
      begin
        result = Api::Certificate.find_public_by_serial(serial).verify(sha224, Base64.decode64(signature), key)
        return result
      rescue
        return false
      end
    end

    def get_devise_list_from_vendor(cloud_id)
      data = RestClient.get( Settings.vendors.asi.host + '/spu/ws/vpc/auth.do', :params => {
        :act => 'login',
        :vpcName => Settings.vendors.asi.vpcName,
        :username => Settings.vendors.asi.account,
        :password => Settings.vendors.asi.password,
        :forcedLogin => '1'
        })
      data = JSON.parse(data)
      logger.debug data

      data = RestClient.get( Settings.vendors.asi.host + '/spu/ws/vpc/device.do', :params => {
        :act => 'getList',
        :accessToken => data['accessToken'],
        :username => cloud_id
        })
      logger.debug data

      return data
    end

    # 將從 Vendor 取回的 vendor device 資料存入 DB
    def save_data_to_db(device_list, user_id)

      saved_vendor_devices = []

      # 假如 user 在 vendor 端有做解除配對的工作，那麼就不會回傳那台 device 的資料，
      # 但是 vendor_devices 先前可能已經存了該 device 的資料，
      # 因此最好的做法是將原本該 user 的 vendor device 全部刪除，全部重新寫入，
      # 可確保 DB 當中的資料都是正確的資料。

      # 先刪除該 user 原本在 vendor_devices 當中所存的 device 資料
      VendorDevice.destroy_all(user_id: user_id)

      # devices 是從 ASI 取回的 user vendor devices 資料
      devices = JSON.parse(device_list)["data"]

      unless devices.blank?
        # 將取回的資料全部寫入 
        devices.each do |device|

          # 確認指定的產品是否存在，若不存在則寫入
          vendor_product = VendorProduct.find_or_initialize_by(product_class_name: device.delete("productClass") , model_class_name: device.delete("modelName"))
          vendor_product.update(vendor_id: 1)


          vendor_device = VendorDevice.create(
            user_id: user_id,
            udid: device.delete("deviceId"),
            vendor_id: 1,
            vendor_product_id: vendor_product.id,
            # mac_address: device["macAddress"],
            # mac_range: device["macRange"],
            # mac_address_secondary: device["macAddressSecondary"],
            # mac_range_secondary: device["macRangeSecondary"],
            device_name: device.delete("nickName"),
            firmware_version: device.delete("firmwareVersion"),
            serial_number: device.delete("deviceLicenseKey"),
            ipv4_lan: convert_ip_decimal_to_hex(device.delete("ip")),
            # ipv6_lan: convert_ip_decimal_to_hex(device["ipV6"]),
            # ipv4_wan: convert_ip_decimal_to_hex(device["ipV4Wan"]),
            ipv4_lan_secondary: convert_ip_decimal_to_hex(device.delete("externalIp")),
            # ipv6_lan_secondary: convert_ip_decimal_to_hex(device["ipV6LanSecondary"]),
            # ipv4_wan_secondary: convert_ip_decimal_to_hex(device["ipV4WanSecondary"]),
            online_status: device.delete("isOnline"),
            meta: device.to_json, # 前面先將有欄位存的資料都用 delete 的方式 set 到各個欄位，最後 device 只剩下要放在 meta 的值
            updated_at: Time.now
          )
          saved_vendor_devices << vendor_device
        end
      end
      saved_vendor_devices
    end

    def convert_ip_decimal_to_hex(ip)
      IPAddr.new(ip).to_i.to_s(16).rjust(8, "0") if ip
    end

end
