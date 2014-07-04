class UpnpController < ApplicationController
  before_action :authenticate_user!
  before_action :device_paired_with?, :only => :show
  before_action :service_list_to_json, :only => :update
  
  def show
    get_device_info
    @session = UpnpSession.create(:user_id => current_user.id,
                                  :device_id => @device.id)
    # push_to_queue "upnp_query"

    respond_to do |format|
      format.json { render :json => @session.to_json(:only => [:id, :user_id, :device_id, :service_list]) }
      format.html
    end
  end
  
  def edit
    @session = UpnpSession.find(params[:id])
    @session.service_list = JSON.parse(@session.service_list) if(@session.status == 'form' && !@session.service_list.empty?)
    render :json => @session.to_json(:only => [:id, :device_id, :service_list, :status])
  end

  def update
    @session = UpnpSession.find(params[:id])
    settings = update_permit.merge({:status => :submit})
    result = @session.update_attributes(settings);

    # push_to_queue "upnp_submit" if result

    render :json => {:result => result}.to_json
  end

  def check
    @session = UpnpSession.find(params[:id]);
    render :json => @session.to_json(:only => :status)
  end

  private

  def service_list_to_json
    params[:service_list] = params[:service_list].to_json
  end

  def push_to_queue(job)
    data = {:job => job, :session_id => @session.id}
    sqs = AWS::SQS.new
    queue = sqs.queues.create(Settings.environments.sqs.name)
    queue.send_message(data.to_json)
  end

  def update_permit
    params.permit(:service_list);
  end

  def get_device_info
    @device = Device.find(params[:id])
  end
end
