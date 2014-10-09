class PairingController < ApplicationController
  include PairingHelper
  before_action :authenticate_user!
  before_action :check_device_available, :only => [:index]
  before_action :check_pairing_session, :only => [:check_connection, :reconnect]

  

  # GET /pairing/index/:id
  def index
    init_session
  end

  # GET /pairing/reconnect/:id
  def reconnect
    init_session
    render :json => {:status => @pairing_session['status']}
  end

  # GET /pairing/check_connection/:id
  def check_connection

    check_timeout
    logger.debug('now:' + Time.now().to_f.to_s + ', pairing_session_expire_in:' + @device.pairing_session_expire_in.to_s)

    result = {:status => @pairing_session['status']}
    result[:expire_in] = @device.pairing_session_expire_in if @pairing_session.empty? || !Device.handling_status.include?(@pairing_session['status'])
    render :json => result
  end

  def cancel
    session_id = params[:id]
    pairing = Device.find(session_id).pairing_session
    unless pairing.all.empty?
      pairing.bulk_set 'status' => "cancel"
      pairing.clear
      push_to_queue_cancel("pairing", session_id)
      flash[:notice] = I18n.t("warnings.settings.pairing.canceled")
    end

    redirect_to controller: "discoverer", action: "index"
  end

  private

  def check_timeout
    logger.debug('@pairing_session status:' + @pairing_session['status'])

    expire_in = @device.pairing_session_expire_in.to_i

    if(@pairing_session['status'] == 'start' && (Device::WAITING_TIME.to_i - expire_in) >= 60)
      @device.pairing_session.store('status', :offline)
      @pairing_session['status'] = :offline
      return
    end

    if(@pairing_session['status'] == 'waiting' && expire_in <= 0)
      @device.pairing_session.store('status', :timeout)
      @pairing_session['status'] = :timeout
    end

  end

  def connect_to_device

    waiting_expire_at = (Time.now() + Device::WAITING_TIME).to_i
    job_params = {:user_id => current_user.id,
                  :status => :start,
                  :expire_at => waiting_expire_at}

    logger.info("connect to device params:" + job_params.to_s)
    @device.pairing_session.bulk_set(job_params)
    @device.pairing_session.expire(waiting_expire_at + 0.2.minutes.to_i)

    @pairing_session = job_params
    @pairing_session[:expire_in] = Device::WAITING_TIME.to_i

    AWS::SQS.new.queues.named(Settings.environments.sqs.name).send_message('{"job":"pairing", "device_id":"' + @device.id.to_s + '"}')
    @device.pairing_session.bulk_set job_params

    logger.info("connect to device session:" + @pairing_session.inspect)
  end

  def init_session
    if @pairing_session.empty? || !Device.handling_status.include?(@pairing_session['status'])
      logger.debug('init session:' + @pairing_session.inspect);
      connect_to_device
    else
      @pairing_session[:expire_in] = @device.pairing_session_expire_in
    end
  end
end