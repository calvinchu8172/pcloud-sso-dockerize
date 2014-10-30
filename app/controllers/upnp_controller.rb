# 同步並更新 UPnP 相關設定  
# UPnP 設定流程的狀態如下  
# * start: 向Device 要求目前的UPnP 目前設定
# * form: Device 回傳目前的設定，讓使用者填寫
# * submit: 從Portal 這傳送使用者異動結果給Device
# * updated: 更新成功
# * failure: device 回傳失敗訊息
# * cancel: 過程中，隨時可以取消對該裝置的配對程序
# * timeout: 在同步過程中，device在時間內未對配對流程確認，則判斷為timout  
class UpnpController < ApplicationController
  before_action :authenticate_user!
  before_action :device_paired_with?, :only => :show
  before_action :service_list_to_json, :only => :update

  # GET /upnp/show/:device_encrypted_id
  # 初始化UPnP Session 並向Device 同步UPnP 設定資訊
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

  # GET /upnp/:session_id/edit/
  # 
  def edit

    session_id = params[:id]
    upnp_session = UpnpSession.find(session_id).session.all
    render :json => {:result => 'timeout'} if upnp_session.empty?

    error_message = get_error_msg(upnp_session['error_code'])
    service_list = (upnp_session['status'] == 'form' && !upnp_session['service_list'].empty?)? JSON.parse(upnp_session['service_list']) : {}
    service_list = decide_which_port(upnp_session, service_list) unless service_list.empty?
    path_ip = decide_which_path_ip upnp_session

    result = {:status => upnp_session['status'],
              :device_id => upnp_session['device_id'],
              :error_message => error_message,
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

  # GET /pairing/check/:id
  # for the polling from front end
  # it will check out session is still avaliable
  def check

    session_id = params[:id]
    upnp = UpnpSession.find(session_id)
    upnp_session = upnp.session.all

    error_message = get_error_msg(upnp_session['error_code'])
    path_ip = decide_which_path_ip upnp_session

    service_list = (upnp_session['status'] == 'form' && !upnp_session['service_list'].empty?)? JSON.parse(upnp_session['service_list']) : {}
    service_list = decide_which_port(upnp_session, service_list) unless service_list.empty?

    result = {:status => upnp_session['status'],
              :device_id => upnp_session['device_id'],
              :error_message => error_message,
              :service_list => service_list,
              :path_ip => path_ip,
              :id => session_id
             }
    render :json => result
  end

  # GET /upnp/cancel/:id
  # cancel upnp setting process
  def cancel
    session_id = params[:id]
    @upnp = UpnpSession.find(session_id)
    session = @upnp.session.all
    unless session.empty?
      session['status'] = "cancel"
      @upnp.session.update(session)
      push_to_queue_cancel("get_upnp_service", @upnp.id)
    end

    redirect_to :authenticated_root
  end

  private

  def same_subnet? device_ip
    request.remote_ip == device_ip
  end

  def decide_which_port(upnp_session, service_list)
    device = Device.find upnp_session['device_id']
    port = same_subnet?(device.session.hget('ip')) ? "lan_port" : "wan_port"
    service_list.each do |service|
      service['port'] = service[port]
    end
    service_list
  end

  def decide_which_path_ip upnp_session
    device = Device.find upnp_session['device_id']
    same_subnet?(device.session.hget('ip')) ? upnp_session['lan_ip'] : device.session.hget('ip')
  end

  def service_list_to_json
    params[:service_list] = params[:service_list].to_json
  end

  def push_to_queue(job)
    data = {:job => job, :session_id => @upnp.id}
    sqs = AWS::SQS.new
    queue = sqs.queues.named(Settings.environments.sqs.name)
    queue.send_message(data.to_json)
  end

  def update_permit
    params.permit(:service_list);
  end

  def get_device_info
    @device_ip = @device.session.hget(:ip)
  end

  def get_error_msg error_code
    if UpnpSession.handling_error_code?(error_code)
      I18n.t("warnings.settings.upnp.error_code.num_" + error_code)
    else
      I18n.t("warnings.settings.upnp.not_found")
    end
  end
end
