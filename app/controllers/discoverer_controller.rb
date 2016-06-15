# 協助User尋找可被配對的Device
# 共有兩種方式尋找可配對裝置
# 1. 透過Public IP 搜尋
# 2. 輸入mac address 與 serial number 搜尋
class DiscovererController < ApplicationController
  include PairingHelper

  before_action :authenticate_user!
  before_filter :check_device_available, :only => [:check]

  def index
    raw_result = Array.new
    search_available_device.each do |device|
      next if(device.product.blank?)
      raw_result.push({:device_id => device.encoded_id,
        :paired => device.paired?,
        :product_name => device.product.name,
        :model_class_name => device.product.model_class_name,
        :mac_address => device.mac_address.scan(/.{2}/).join(":"),
        :firmware_version => device.firmware_version,
        :img_url => device.product.asset.url(:thumb),
        :has_indicator_module => device.find_module_list.include?('indicator')
        })
    end
    service_logger.note({available_to_pair: raw_result})

    @result = raw_result
    respond_to do |format|
      format.html # index.html.erb
      format.json {
        render :json => @result
      }
    end
  end

  def add
    @device = Device.new
  end

  def search
    unless mac_address_valid?(params[:device][:mac_address])
      flash[:error] = I18n.t("warnings.invalid")
      redirect_to action: 'add'
      return
    end
    params[:device][:mac_address].gsub!(/:/, '')
    service_logger.note({searching_device: params[:device]})
    device = Device.search(params[:device][:mac_address], params[:device][:serial_number])

    logger.info("searched device:" + params[:device][:mac_address].inspect)
    
    if device.blank?
      flash[:alert] = I18n.t("errors.messages.not_found")
      redirect_to action: 'add'
    elsif device.paired?
      flash[:alert] = I18n.t("warnings.settings.pairing.pair_already")
      redirect_to action: 'add'
    else
      redirect_to action: 'check', id: device.encoded_id
    end
  end

  def check
    logger.info "checking device id:" + @device.id.to_s
  end

  #搜尋條件如下
  # 1. 同樣的public IP
  # 2. 裝置非本人配對中
  def search_available_device
    available_device_list = []
    available_ip_list = Redis::HashKey.new(Device::IP_ADDRESSES_KEY + request.remote_ip.to_s).keys

    service_logger.note({device_in_lan: available_ip_list})

    Device.includes(:product).where('id in (?)', available_ip_list).each do |device|
      if device.is_available_to_pair?(current_user.id)
        available_device_list << device
      end
    end
    available_device_list
  end

  def indicate
    device_id = params[:id]
    indicator_session = DeviceIndicatorSession.create
    device = Device.find_by_encoded_id device_id
    session = { device_id: device.id }
    indicator_session.session.bulk_set(session)

    job = {:job => 'led_indicator', :session_id => indicator_session.id}
    AwsService.send_message_to_queue(job)

    render :json => { "result" => "success" }, status: 200
  end


  def mac_address_valid?(mac_address)
    # Sample: 20:13:10:00:00:A0  |  2013100000A0
    /^((([0-9A-F]{2}:){5}[0-9A-F]{2})|([0-9A-F]{12}))$/i.match(mac_address)
  end
end
