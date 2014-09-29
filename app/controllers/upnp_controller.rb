class UpnpController < ApplicationController
  before_action :authenticate_user!
  before_action :device_paired_with?, :only => :show
  before_action :service_list_to_json, :only => :update

  def show
    get_device_info
    @session = {:user_id => current_user.id,
                :device_id => @device.id,
                :status => 'start'}

    @upnp = UpnpSession.create
    @upnp.session.bulk_set(@session)

    push_to_queue "upnp_query"
    @session[:id] = @upnp.id
    respond_to do |format|
      format.json { render :json => {:id => upnp.id, :user_id => current_user.id, :device_id => current_user.id} }
      format.html
    end
  end

  def edit

    session_id = params[:id]
    upnp_session = UpnpSession.find(session_id).session.all
    render :json => {:result => 'timeout'} if upnp_session.empty?

    service_list = (upnp_session['status'] == 'form' && !upnp_session['service_list'].empty?)? JSON.parse(upnp_session['service_list']) : {}
    path_ip = decide_which_path_ip upnp_session

    result = {:status => upnp_session['status'],
              :device_id => upnp_session['device_id'],
              :service_list => service_list,
              :path_ip => path_ip,
              :id => session_id
             }
    logger.debug('edit result:' + result.inspect)
    render :json => result
  end

  def update
    @upnp = UpnpSession.find(params[:id])
    settings = update_permit.merge({:status => :submit})
    result = @upnp.session.update(settings);

    push_to_queue "upnp_submit" if result

    render :json => {:result => result}.to_json
  end

  def check

    session_id = params[:id]
    upnp = UpnpSession.find(session_id)
    upnp_session = upnp.session.all
    path_ip = decide_which_path_ip upnp_session

    service_list = (upnp_session['status'] == 'form' && !upnp_session['service_list'].empty?)? JSON.parse(upnp_session['service_list']) : {}

    result = {:status => upnp_session['status'],
              :device_id => upnp_session['device_id'],
              :service_list => service_list,
              :path_ip => path_ip,
              :id => session_id
             }
    render :json => result
  end

  def cancel
    session_id = params[:id]
    @upnp = UpnpSession.find(session_id)
    session = @upnp.session.all
    unless session.empty?
      session['status'] = "cancel"
      @upnp.session.update(session)
      push_to_queue_cancel("upnp", @upnp.id)
    end

    redirect_to :authenticated_root
  end

  private

  def decide_which_path_ip upnp_session
    device = Device.find upnp_session['device_id']
    request.remote_ip == device.session.hget('ip') ? upnp_session['lan_ip'] : request.remote_ip
  end

  def service_list_to_json
    params[:service_list] = params[:service_list].to_json
  end

  def push_to_queue(job)
    data = {:job => job, :session_id => @upnp.id}
    sqs = AWS::SQS.new
    queue = sqs.queues.create(Settings.environments.sqs.name)
    queue.send_message(data.to_json)
  end

  def update_permit
    params.permit(:service_list);
  end

  def get_device_info
    @device = Device.find(params[:id])
    @device_ip = @device.session.hget(:ip)
  end
end
