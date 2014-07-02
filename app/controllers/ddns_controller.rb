class DdnsController < ApplicationController
  before_action :authenticate_user!

  def setting
    @ddns_session = DdnsSession.new
    @device = Device.find(params[:id])
  end

  def success
    @ddns_session = DdnsSession.find(params[:id])
  end

  # set error message and redirect to setting page
  def failure
    flash[:error] = "更新失敗，請稍後再試!"
    redirect_to action: 'setting', id: params[:id]
  end

  def check
    @ddns_params = params[:ddns_session]
    ddns = Ddns.exists?(:full_domain => @ddns_params[:full_domain])

    # If full domain was exits, it will redirct to setting page and display error message
    if ddns
      flash[:error] = @ddns_params[:full_domain]+"已存在"
      redirect_to action: 'setting', id: @ddns_params[:device_id]
      return
    end

    save_ddns_setting
  end

  # send ajax
  def status
    @session = DdnsSession.find(params[:id])
    render :json => @session.to_json(:only => [:id, :device_id, :full_domain, :status])
  end

  private
    def push_to_queue
      data = {:job => "ddns", :session_id => @session.id}
      sqs = AWS::SQS.new
      queue = sqs.queues.create(Settings.environments.sqs.name)
      queue.send_message(data.to_json)
    end

    # If full domain was not exits, it will insert data to database and redirct to success page
    def save_ddns_setting
      @session = DdnsSession.new(device_id: @ddns_params[:device_id], full_domain: @ddns_params[:full_domain])
      if @session.save
        push_to_queue
        redirect_to action: 'success', id: @session.id
      end
    end
end
