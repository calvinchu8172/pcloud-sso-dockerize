class PairingController < ApplicationController
  include PairingHelper
  before_action :authenticate_user!
  before_action :check_device_available, :only => [:index, :waiting]
  before_action :check_pairing_session, :only => [:check_connection, :reconnect]

  # GET /pairing/index/:id
  # Cancel pairing process if the device is pairing with same user
  def index
    logger.debug('init session:' + @pairing_session.inspect)
    connect_to_device 
    redirect_to action: "waiting", id: @device.encrypted_id
  end

  # GET /pairing/waiting/:id
  def waiting

    return redirect_to action: "index", id: @device.encrypted_id if @pairing_session.empty?

    @pairing_session['expire_in'] = @device.pairing_session_expire_in
    logger.debug('pairing_session:' + @pairing_session.inspect);
  end

  # GET /pairing/check_connection/:id
  # for the polling from front end
  # it will check out session is still avaliable
  def check_connection

    check_timeout
    logger.debug('now:' + Time.now().to_f.to_s + ', pairing_session_expire_in:' + @device.pairing_session_expire_in.to_s)

    result = {:status => @pairing_session['status'], :expire_at => @pairing_session['expire_at']}
    result[:expire_in] = @device.pairing_session_expire_in if @pairing_session.empty? || !Device.handling_status.include?(@pairing_session['status'])
    render :json => result
  end

  # GET /pairing/cancel/:id
  # break the pairing process
  def cancel
    device = Device.find_by_encrypted_id(URI.decode(params[:id]))
    pairing = device.pairing_session
    unless pairing.all.empty?
      pairing.bulk_set 'status' => "cancel"
      push_to_queue_cancel("pairing", device.id)
      flash[:notice] = I18n.t("warnings.settings.pairing.canceled")
    end

    redirect_to controller: "discoverer", action: "index"
  end

  private

  def check_timeout
    logger.debug('@pairing_session status:' + @pairing_session['status'])

    expire_in = @device.pairing_session_expire_in.to_i

    if(@pairing_session['status'] == 'start' && (Pairing::WAITING_PERIOD.to_i - expire_in) >= Pairing::START_PERIOD.to_i)
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

    waiting_expire_at = (Time.now() + Pairing::WAITING_PERIOD).to_i
    job_params = {:user_id => current_user.id,
                  :status => :start,
                  :expire_at => waiting_expire_at}

    logger.info("connect to device params:" + job_params.to_s)
    @device.pairing_session.bulk_set(job_params)
    @device.pairing_session.expire((Pairing::WAITING_PERIOD + 0.2.minutes).to_i)

    @pairing_session = job_params

    AWS::SQS.new.queues.named(Settings.environments.sqs.name).send_message('{"job":"pairing", "device_id":"' + @device.id.to_s + '"}')
    @device.pairing_session.bulk_set job_params

    @pairing_session[:expire_in] = Pairing::WAITING_PERIOD.to_i

    logger.info("connect to device session:" + @pairing_session.inspect)
  end

end