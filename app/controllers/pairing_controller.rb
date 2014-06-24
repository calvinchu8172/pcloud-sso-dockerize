class PairingController < ApplicationController
  include PairingHelper
  before_action :authenticate_user!
  before_filter :check_device_avaliable,

  def index
  	device_id = params[:id];
    @session = PairingSession.create(:user_id => current_user.id, :device_id => device_id, :expire_at => (Time.now + (12.minutes)))
    push_to_queue
  end

  def push_to_queue
  	data = {:job => "pair", :session_id => @session.id}
  	sqs = AWS::SQS.new
  	queue = sqs.queues.create()
  	queue.send_message(data.to_json)
  end
end
