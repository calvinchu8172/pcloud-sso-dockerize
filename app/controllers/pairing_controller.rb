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
    check_status
    
    render :json => @session.to_json(:only => [:id, :status])
  end

  # GET /pairing/waiting/:id
  def waiting
    session_id = params[:id]
    @session = PairingSession.find(session_id)

    render :json => @session.to_json(:only => [:id, :status])
  end

  private

  def check_status
    if @session.status == "start"
      @session.status = :offline
      @session.save!
    end
  end

  def init_session
    if @last_session.nil?
      connect_to_device
    else
      @session = @last_session
    end
  end
  def connect_to_device
    @device = Device.find(params[:id])

    job = Job::PairingMessage.new
    job.push({:user_id => current_user.id,
              :device_id => @device.id,
              :expire_at => (Time.now + (12.minutes))})
    @session = job.session
  end
  def init_session
    if @last_session.nil?
      connect_to_device
    else
      @session = @last_session
    end
  end
end