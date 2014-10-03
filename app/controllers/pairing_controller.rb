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
    render :json => {:status => @session['status']}
  end

  # GET /pairing/check_connection/:id
  def check_connection
    check_timeout
    logger.debug('now:' + Time.now().to_f.to_s + ', expire:' + @device.pairing_session.get('start_expire_at'));
    logger.debug('pairing_session_expire_in:' + @device.pairing_session_expire_in.to_s)

    result = {:status => @session['status']}
    result[:expire_in] = @device.pairing_session_expire_in.to_i.to_s if @session['status'] == 'waiting'
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
    logger.debug('@session status:' + @session['status'])

    if(@device.pairing_session_expire_in.to_i <= 0 && ['start','waiting'].include?(@session['status']))

      new_status = @session['status'] == 'start'? 'offline': 'timeout'

      @device.pairing_session.store('status', new_status)
      @session['status'] = new_status
    end
  end

  def connect_to_device

    job_params = {:user_id => current_user.id,
                  :status => :start,
                  :start_expire_at => (Time.now() + 1.minutes).to_i}
    logger.info("connect to device params:" + job_params.to_s)
    @device.pairing_session.bulk_set(job_params)
    @device.pairing_session.expire(12.minutes.to_i)

    @session = job_params
    AWS::SQS.new.queues.named(Settings.environments.sqs.name).send_message('{"job", "pairing", "device_id":"' + @device.id.to_s + '"}')
    @device.pairing_session.bulk_set job_params
    logger.info("connect to device session:" + @session.inspect)
  end

  def init_session
    if @session.empty? || !Device.handling_status.include?(@session['status'])
      logger.debug('init session:' + @session.inspect);
      connect_to_device
    end
  end

end