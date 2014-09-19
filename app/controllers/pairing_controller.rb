class PairingController < ApplicationController
  include PairingHelper
  before_action :authenticate_user!
  before_action :check_device_available, :only => [:index, :check_connection]
  before_action :check_pairing_session, :only => [:check_connection, :waiting]

  # GET /pairing/index/:id
  def index
    init_session
  end

  # GET /pairing/reconnect/:id
  def reconnect
    @device = Device.find(params[:id])
    init_session
    render :json => @session.to_json(:only => [:id, :status])
  end

  # GET /pairing/check_connection/:id
  def check_connection
    device = params[:id]
    @session = PairingSession.find(session_id)

    check_timeout

    render :json => @session.to_json(:only => [ :id, :status], :methods => :expire_in)
  end

  # GET /pairing/waiting/:id
  def waiting
    session_id = params[:id]
    @session = PairingSession.find(session_id)

    render :json => @session.to_json(:only => [ :id, :status ], :methods => :expire_in)
  end

  private

  def check_timeout
    case @session.status
    when :start
      if((Time.now.to_f - @session.created_at.to_f) > 60)
        @session.status = :offline
        @session.save!
      end
    when :waiting
      if((Time.now.to_f - @session.updated_at.to_f) > 599)
        @session.status = :failure
        @session.save!
      end
    end
  end

  def connect_to_device
    
    job_params = {:user_id => current_user.id,
                  :status => :start}
    logger.info("connect to device params:" + job_params.to_s)
    @device.pairing_session.bulk_set(job_params)
    @session = job_params 
    AWS::SQS.new.queues.create(Settings.environments.sqs.name).send_message('{"device_id":"' + @device.id + '"}')
    # job = Job::PairingMessage.new
    # job.push(job_params)
    # @session = job.session
    logger.info("connect to device session:" + @session.inspect)
  end
  
  def init_session
    logger.info "init session last_session:" + @last_session.inspect
    if @session.nil?
      connect_to_device
    else
      @session = @last_session
      logger.info("resume from pairing device id:" + @device.id.to_s)
    end
  end
end