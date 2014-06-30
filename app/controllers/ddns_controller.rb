class DdnsController < ApplicationController
  before_action :authenticate_user!

  def setting
    @ddns_session = DdnsSession.new
    @device = Device.find(params[:id])
  end

  def success
    @ddns_session = DdnsSession.find(params[:id])
    connect_to_device
  end

  def check
    ddns_params = params[:ddns_session]
    ddns = Ddns.exists?(:full_domain => ddns_params[:full_domain])
    puts ddns

    # If full domain was exits, it will redirct to setting page and display error message
    if ddns
      flash[:error] = ddns_params[:full_domain]+"已存在"
      redirect_to '/ddns/setting/' + ddns_params[:device_id]

    # If full domain was not exits, it will insert data to database and redirct to success page
    else
      ddns_session = DdnsSession.new(device_id: ddns_params[:device_id], full_domain: ddns_params[:full_domain])
      if ddns_session.save
        redirect_to '/ddns/success/' + ddns_session.id.to_s
      end
    end
  end

  private
    def push_to_queue
      data = {:job => "ddns", :session_id => @session.id}
      sqs = AWS::SQS.new
      queue = sqs.queues.create(Settings.environments.sqs.name)
      queue.send_message(data.to_json)
    end

    def connect_to_device
      @session = DdnsSession.find(params[:id])
      push_to_queue
    end
end
