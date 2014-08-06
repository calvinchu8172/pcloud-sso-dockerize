class PairingController < ApplicationController
  include PairingHelper
  before_action :authenticate_user!
  before_action :check_device_available, :only => :index
  before_action :check_pairing_session, :only => [:check_connection, :waiting]

  before_action

  # GET /pairing/index/:id
  def index
    @device = Device.find(params[:id])
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
    session_id = params[:id]
    @session = PairingSession.find(session_id)

    logger.debug "session: " + @session.to_json
    if @session.status == "start" && (Time.now.to_f - @session.created_at.to_f) > 60
      @session.status = :offline
      @session.save!
    end

    render :json => @session.to_json(:only => [:id, :status])
  end

  # GET /pairing/waiting/:id
  def waiting
    session_id = params[:id]
    @session = PairingSession.find(session_id)

    render :json => @session.to_json(:only => [:id, :status])
  end

  private

  def connect_to_device
    @device = Device.find(params[:id])

    job_params = {:user_id => current_user.id,
                  :device_id => @device.id,
                  :expire_at => (Time.now + (12.minutes))}
    logger.info("connect to device params:" + job_params.to_s)
    job = Job::PairingMessage.new
    job.push(job_params)
    @session = job.session
  end
  
  def init_session
    if @last_session.nil?
      connect_to_device
    else
      @session = @last_session
      logger.info("resume from pairing session id:" + @session.id.to_s)
    end
  end
end