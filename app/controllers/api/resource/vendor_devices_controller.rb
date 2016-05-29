class Api::Resource::VendorDevicesController < Api::Base
  before_action :check_params, :except => :crawl
  before_action :check_cloud_id, :except => :crawl
  before_action :check_device, :except => :crawl
  before_action :check_signature, :except => :crawl

  def index
    begin
      @updated_vendor_devices = [] # save_data_to_db 會將更新過的 vendor_devices 存入一個 array

      # 目前因為只能用ASI給的cloud_id去測他們的API，所以需要先用他們給的cloud_id
      # cloud_id = 'zyxoperator'
      # password = 'zyxoperator'
      vendor_devices = VendorDevice.where(user_id: @user.id)
      # vendor_devices = VendorDevice.where(user_id: cloud_id)
      cloud_id = @user.encoded_id
      # cloud_id = valid_params[:cloud_id]

      # 假如原本的user_id找不到vendor_devices，則去打ASI的API撈資料，存到DB，再傳json給NAS
      if vendor_devices.blank?
        device_list = get_devise_list_from_vendor(cloud_id)
        save_data_to_db(device_list, @user.id)
      else
      # 假如user_id找到vendor_devices，看每一個vendor_device的update日期是否超過十分鐘，
      # 若超過，則去打ASI的API撈資料，存到DB，再傳json給NAS
      # 若沒超過，就略過此步驟，最後再掃一次user的vendor_devices，回傳json
        vendor_devices.each do |vendor_device|
          if Time.now - vendor_device.updated_at > 10*60
            device_list = get_devise_list_from_vendor(cloud_id)
            save_data_to_db(device_list, @user.id)
          end
        end
      end

      scan_again_vendor_devices = VendorDevice.where(user_id: @user.id)
      render :json => { "cloud_id" => cloud_id,
                        "device_list" => scan_again_vendor_devices }, status: 200

    rescue Exception => error
      render :json => { error_code: "300", description: "Unexpected error." }, status: 400 if error
    end
  end

  def crawl
    begin
      @updated_vendor_devices = [] # save_data_to_db 會將更新過的 vendor_devices 存入一個 array
      unchanged_vendor_devices = []

      over_time_vendor_devices = VendorDevice.select(:id, :user_id, :udid, :device_name, :serial_number, :updated_at).where.not(updated_at: (Time.now - 10*60)..Time.now)
      over_time_vendor_devices.each do |vendor_device|
        cloud_id = vendor_device.user.encoded_id
        # cloud_id = 'zyxoperator'
        logger.debug cloud_id
        device_list = get_devise_list_from_vendor(cloud_id)
        save_data_to_db(device_list, vendor_device.user_id)
      end

      unchanged_vendor_devices = over_time_vendor_devices - @updated_vendor_devices

      render :json => { "result" => "success",
                        "over_time_vendor_devices" => over_time_vendor_devices,
                        "updated_vendor_devices" => @updated_vendor_devices,
                        "unchanged_vendor_devices" => unchanged_vendor_devices
                         }, status: 200
    rescue Exception => error
      puts error.message
      render :json => { error_code: "300", description: "Unexpected error." }, status: 400 if error
    end
  end

  def show
  end

  def create
    # render :json => { "result" => "success" }, status: 200
  end

  def update
  end

  def destroy
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
      data = RestClient.get( Settings.asi.host + '/spu/ws/vpc/auth.do', :params => {
        :act => 'login',
        :vpcName => 'ZYX',
        :username => Settings.asi.account,
        :password => Settings.asi.password,
        :forcedLogin => '1'
        })
      data = JSON.parse(data)
      logger.debug data

      data = RestClient.get( Settings.asi.host + '/spu/ws/vpc/device.do', :params => {
        :act => 'getList',
        :accessToken => data['accessToken'],
        :username => cloud_id
        })
      logger.debug data

      return data
    end

    def save_data_to_db(device_list, user_id)
      devices = JSON.parse(device_list)["data"]

      devices.each do |device|
        vendor_product = VendorProduct.find_or_initialize_by(product_class_name: device["productClass"] , model_class_name: device["modelName"])
        vendor_product.update(vendor_id: 1)

        vendor_device = VendorDevice.find_or_initialize_by(udid: device["deviceId"])
        array = ["deviceLicenseKey", "productClass", "ip", "isOnline", "modelName", "nickName", "externalIp", "firmwareVersion", "deviceId"]
        vendor_device.update(
          user_id: user_id,
          udid: device["deviceId"],
          vendor_id: 1,
          vendor_product_id: vendor_product.id,
          mac_address: valid_params[:mac_address],
          mac_range: device["macRange"],
          mac_address_secondary: device["macAddressSecondary"],
          mac_range_secondary: device["macRangeSecondary"],
          device_name: device["nickName"],
          firmware_version: device["firmwareVersion"],
          serial_number: device["deviceLicenseKey"],
          ipv4_lan: convert_ip_decimal_to_hex(device["ip"]),
          ipv6_lan: convert_ip_decimal_to_hex(device["ipV6"]),
          ipv4_wan: convert_ip_decimal_to_hex(device["ipV4Wan"]),
          ipv4_lan_secondary: convert_ip_decimal_to_hex(device["externalIp"]),
          ipv6_lan_secondary: convert_ip_decimal_to_hex(device["ipV6LanSecondary"]),
          ipv4_wan_secondary: convert_ip_decimal_to_hex(device["ipV4WanSecondary"]),
          online_status: device["isOnline"],
          meta: device.delete_if { |key, _| array.include? key }.to_json,
          updated_at: Time.now
        )
      @updated_vendor_devices << vendor_device
      end

      @updated_vendor_devices.uniq! { |vendor_device| vendor_device[:id] }  # 有重複更新到的vendor_device，只取一個輸出結果
    end

    def convert_ip_decimal_to_hex(ip)
      IPAddr.new(ip).to_i.to_s(16).rjust(8, "0") if ip
    end

end
