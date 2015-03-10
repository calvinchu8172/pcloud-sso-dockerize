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
      logger.debug('get device product:' + device.product.to_json)
      next if(device.product.blank?)
      logger.info "discovered device id:" + device.id.to_s + ", product name:" + device.product.name
      raw_result.push({:device_id => device.escaped_encrypted_id,
        :paired => device.paired?,
        :product_name => device.product.name,
        :model_class_name => device.product.model_class_name,
        :mac_address => device.mac_address.scan(/.{2}/).join(":"),
        :firmware_version => device.firmware_version,
        :img_url => device.product.asset.url(:thumb)})
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

    valid = mac_address_valid?(params[:device][:mac_address])
    params[:device][:mac_address].gsub!(/:/, '')

    service_logger.note({searching_device: params[:device]})

    devices = Device.where(params['device']);
    logger.info "searched device:" + params['device'].inspect

    if !valid
      flash[:error] = I18n.t("warnings.invalid")
      redirect_to action: 'add'
    elsif devices.empty?
      flash[:alert] = I18n.t("errors.messages.not_found")
      redirect_to action: 'add'
    elsif devices.first.paired?
      flash[:alert] = I18n.t("warnings.settings.pairing.pair_already")
      redirect_to action: 'add'
    else
      redirect_to action: 'check', id: devices.first.escaped_encrypted_id
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
    available_ip_list = Redis::HashKey.new(Device.ip_addresses_key_prefix + request.remote_ip.to_s).keys

    service_logger.note({device_in_lan: available_ip_list})

    Device.where('id in (?)', available_ip_list).each do |device|

      pairing_session = device.pairing_session.all
      pairing = device.pairing_session.size != 0 && Device.handling_status.include?(pairing_session['status']) && pairing_session['user_id'] != current_user.id.to_s
      presence = device.presence?

      available_device_list << device if !pairing && presence
    end

    logger.debug('result of searching available device list:' + available_device_list.inspect)
    available_device_list
  end

  def mac_address_valid?(mac_address)
    # Sample: 20:13:10:00:00:A0  |  2013100000A0
    /^((([0-9A-F]{2}:){5}[0-9A-F]{2})|([0-9A-F]{12}))$/i.match(mac_address)
  end
end
