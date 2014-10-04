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
      raw_result.push({:device_id => device.id, :product_name => device.product.name, :img_url => device.product.asset.url(:thumb)})
    end

    @result = raw_result.to_json
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
    device = Device.where(params['device']);
    logger.info "searched device:" + params['device'].inspect

    if !valid
      flash[:error] = I18n.t("warnings.invalid")
      redirect_to action: 'add'
    elsif device.empty?
      flash[:alert] = I18n.t("errors.messages.not_found")
      redirect_to action: 'add'
    else
      redirect_to action: 'check', id: device.first.id
    end
  end

  def check
    @device = Device.find(params[:id])
    logger.info "checking device id:" + @device.id.to_s
  end


  def search_available_device

    available_device_list = []
    available_ip_list = Redis::HashKey.new(Device.ip_addresses_key_prefix + request.remote_ip.to_s).keys

    Device.where('id in (?)', available_ip_list).each do |device|
      available_device_list << device unless device.pairing_session.size != 0 && Device.handling_status.include?(device.pairing_session.get(:status))
    end
    logger.debug('result of searching available device list:' + available_device_list.inspect)
    available_device_list
  end

  def mac_address_valid?(mac_address)
    # Sample: 20:13:10:00:00:A0  |  2013100000A0
    /^((([0-9A-F]{2}:){5}[0-9A-F]{2})|([0-9A-F]{12}))$/i.match(mac_address)
  end
end
