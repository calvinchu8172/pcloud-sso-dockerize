class PairingController < ApplicationController
  include PairingHelper
  before_action :authenticate_user!
  before_action :check_device_available, :only => :index
  before_action :check_pairing_session, :only => [:check_connection, :waiting]
  # before_action :check_device_registered_for_rest, :except => :index
  # before_action :check_paired_for_rest, :except => :index

  before_action

  # GET /pairing/index/:id
  def index
    connect_to_device
  end

  # GET /pairing/reconnect/:id
  def reconnect
    connect_to_device
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

  def push_to_queue
  	data = {:job => "pair", :session_id => @session.id}
  	sqs = AWS::SQS.new
  	queue = sqs.queues.create(Settings.environments.sqs.name)
  	queue.send_message(data.to_json)
  end

  def connect_to_device
    @device = Device.find(params[:id])
    @session = PairingSession.create(:user_id => current_user.id,
                                     :device_id => @device.id,
                                     :expire_at => (Time.now + (12.minutes)))
    push_to_queue
  end
end