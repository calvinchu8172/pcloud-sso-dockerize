class PersonalController < ApplicationController
  before_action :authenticate_user!
  before_action :check_device_available, only: [:device_info]
  before_action :check_device_info_session, only: [:check_status]

  def index
    @pairing = Pairing.owner.where(user_id: current_user.id)
    service_logger.note({paired_device: @pairing})

    if @pairing.empty?
      @paired = false
      flash[:alert] = flash[:notice] ? flash[:notice] : I18n.t("warnings.no_pairing_device")
      redirect_to "/discoverer/index" and return
    end
  end

  def profile
    @language = @locale_options.has_value?(current_user.language) ? @locale_options.key(current_user.language) : "English"
  end

  def check_device_available
    encrypted_device_id = params[:id] || ''
    render :json => { "result" => "failed" }, status: 400 and return if encrypted_device_id.blank?

    @device = Device.find_by_encrypted_id(encrypted_device_id)
    render :json => { "result" => "failed" }, status: 400 and return if @device.nil?
  end

  def device_info
    connect_to_device
    render :json => @session, status: 200
  end

  def connect_to_device
    waiting_expire_at = (Time.now() + DeviceInfoSession::WAITING_PERIOD).to_i

    @session = { :user_id => current_user.id,
      :device_id => @device.id,
      :status => :start,
      :expire_at => waiting_expire_at }
    device_info_session = DeviceInfoSession.create
    device_info_session.session.bulk_set(@session)
    device_info_session.session.expire((DeviceInfoSession::WAITING_PERIOD + 0.2.minutes).to_i)

    @session[:session_id] = device_info_session.escaped_encrypted_id
    @session[:expire_in] = DeviceInfoSession::WAITING_PERIOD.to_i
    job = {:job => 'device_info', :session_id => @device_info_session.id}
    AWS::SQS.new.queues.named(Settings.environments.sqs.name).send_message(job.to_s)
  end



  def check_device_info_session
    encrypted_session_id = params[:id] || ''
    render :json => { "result" => "failed" }, status: 400 and return if encrypted_session_id.blank?

    @device_info_session = DeviceInfoSession.find_by_encrypted_id(URI.decode(encrypted_session_id))
    render :json => { "result" => "failed" }, status: 400 and return if @device_info_session.nil?

    @session = @device_info_session.session.all
    render :json => { "result" => "failed" }, status: 400 and return if @session.nil?
  end

  def check_timeout
    expire_in = @device_info_session.expire_in.to_i
    @session['expire_in'] = expire_in
    if(@session['status'] == 'start' && expire_in <= 0)
      @device_info_session.session.store('status', :timeout)
      @session['status'] = :timeout
    end
  end

  def check_status
    check_timeout
    @session['session_id'] = @device_info_session.escaped_encrypted_id
    render :json => @session, status: 200
  end

  protected
    def get_info(pairing)
      device = pairing.device
      info_hash = Hash.new
      info_hash[:model_class_name] = device.product.model_class_name
      info_hash[:firmware_version] = device.firmware_version
      info_hash[:mac_address] = device.mac_address.scan(/.{2}/).join(":")
      info_hash[:ip] = device.session.hget :ip || device.ddns.get_ip_addr
      if device.ddns
        info_hash[:class_name] = "blue"
        # remove ddns domain name last dot
        info_hash[:title] = device.ddns.hostname + "." + Settings.environments.ddns.chomp('.')
        info_hash[:date] = device.ddns.updated_at.strftime("%Y/%m/%d")
      else
        info_hash[:class_name] = "gray"
        info_hash[:title] = I18n.t("warnings.not_config")
      end
      info_hash
    end

    helper_method :get_info
end
