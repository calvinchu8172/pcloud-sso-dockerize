class DiscovererController < ApplicationController
  include PairingHelper
  before_action :authenticate_user!
  before_filter :check_device_available, :only => [:check]

  def index

    # @device_session_list = search_available_device.where(:ip => request.remote_ip)
    @device_session_list = search_available_device.where(:ip => request.remote_ip, :xmpp_account => current_user.email)
    raw_result = Array.new
    @device_session_list.each do |session|
      next if(session.device.product.blank?)
      logger.info "discovered device id:" + session.device.id.to_s + ", product name:" + session.device.product.name
      raw_result.push({:device_id => session.device.id, :product_name => session.device.product.name, :img_url => session.device.product.asset.url(:thumb)})
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

  private

  def search_available_device

    # PairingSession.handling().select(:device_id)
    DeviceSession.where("device_id not in (?) AND device_id not in (?)" , PairingSession.handling.where.not(:user_id => current_user.id).select(:device_id), Pairing.owner.select(:device_id))
  end

  def mac_address_valid?(mac_address)
    # Sample: 20:13:10:00:00:A0  |  2013100000A0
    /^((([0-9A-F]{2}:){5}[0-9A-F]{2})|([0-9A-F]{12}))$/i.match(mac_address)
  end
end
