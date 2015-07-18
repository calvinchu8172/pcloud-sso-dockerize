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
  before_action :deleted_extra_key, :only => :update
  before_action :service_list_to_json, :only => :update
  before_action :is_device_support?, :only => :show
  before_action :check_session_available, :only => [:edit, :reload]

  # GET /upnp/show/:device_encrypted_id
  # 初始化UPnP Session 並向Device 同步UPnP 設定資訊
  def show
    get_device_info
    @session = { :user_id => current_user.id, :device_id => @device.id, :status => 'start' }

    @upnp = UpnpSession.create
    @upnp.session.bulk_set(@session)

    push_to_queue "upnp_query"
    @session[:id] = @upnp.id

    service_logger.note({start_upnp: @session})
  end

  # GET /upnp/:session_id/edit/
  def edit
    error_message = get_error_msg(@upnp_session['error_code'])
    service_list = (@upnp_session['status'] == 'form' && !@upnp_session['service_list'].empty?) ? JSON.parse(@upnp_session['service_list']) : []
    service_list = decide_which_port(@upnp_session, service_list) unless service_list.empty?
    service_list = decide_which_description(service_list) unless service_list.empty?
    path_ip = decide_which_path_ip(@upnp_session)

    used_wan_port_list = @upnp_session['used_wan_port_list'].blank? ? [] : JSON.parse(@upnp_session['used_wan_port_list'])
    used_wan_port_list.map! { |port_num| port_num.to_i }

    result = {:status => @upnp_session['status'],
              :device_id => @upnp_session['device_id'],
              :error_message => error_message,
              :service_list => service_list,
              :used_wan_port_list => used_wan_port_list,
              :path_ip => path_ip,
              :id => @session_id
             }

    service_logger.note({edit_upnp: result})
    render :json => result
  end

  def update
    @upnp = UpnpSession.find(params[:id])

    settings = update_permit.merge({:status => :submit})
    result = @upnp.session.update(settings);

    push_to_queue "upnp_submit" if result

    service_logger.note({edit_upnp: settings})
    render :json => {:result => result}.to_json
  end

  # GET /upnp/reload/:id
  # reload the service list when updating services not all successfully
  def reload
    error_message = get_error_msg(@upnp_session['error_code'])
    path_ip = decide_which_path_ip(@upnp_session)

    service_list = []
    if @upnp_session['status'] == 'reload'
      # restart the session
      @upnp_session['status'] = 'start'
      @upnp.session.update(@upnp_session)
      push_to_queue "upnp_query"

    elsif @upnp_session['status'] == 'form'
      unless @upnp_session['service_list'].empty?
        service_list = JSON.parse(@upnp_session['service_list'])
        unless service_list.empty?
          service_list = decide_which_port(@upnp_session, service_list)
          service_list = decide_which_description(service_list)
        end
      end

      used_wan_port_list = @upnp_session['used_wan_port_list'].blank? ? [] : JSON.parse(@upnp_session['used_wan_port_list'])
      used_wan_port_list.map! { |port_num| port_num.to_i }
    end

    result = {
      :error_message => error_message,
      :service_list => service_list,
      :used_wan_port_list => used_wan_port_list,
      :path_ip => path_ip,
      :id => @session_id,
      :status => @upnp_session['status']
    }
    service_logger.note({reload_upnp_list: result})
    render :json => result
  end

  # GET /upnp/check/:id
  # for the polling from front end, it will check out session is still avaliable
  def check
    session_id = params[:id]
    @upnp = UpnpSession.find(session_id)
    upnp_session = @upnp.session.all

    error_message = get_error_msg(upnp_session['error_code'])
    path_ip = decide_which_path_ip(upnp_session)
    service_list = (got_updated_service_list?(upnp_session) || upnp_session['status'] == 'reload') ? JSON.parse(upnp_session['service_list']) : []
    service_list = decide_which_port(upnp_session, service_list) unless service_list.empty?
    service_list = decide_which_description(service_list) unless service_list.empty?
    service_list = update_result(service_list) unless service_list.empty?
    @upnp.session.update(upnp_session.merge({'status' => 'reload', 'service_list' => service_list.to_json})) if reload_step?(upnp_session)

    result = {:status => upnp_session['status'],
              :device_id => upnp_session['device_id'],
              :error_message => error_message,
              :service_list => service_list,
              :path_ip => path_ip,
              :id => session_id
             }
    service_logger.note({failure_upnp: result}) if failure_step?(upnp_session)
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
    service_logger.note({cancel_upnp: session})
    redirect_to :authenticated_root
  end

  private

    def check_session_available
      @session_id = params[:id]
      @upnp = UpnpSession.find(@session_id)
      @upnp_session = @upnp.session.all
      render :json => { :result => 'timeout' } if @upnp_session.empty?
    end

    def reload_step? upnp_session
      got_updated_service_list?(upnp_session) && upnp_session['status'] == 'form'
    end

    def failure_step? upnp_session
      ['failure', 'timeout'].include?(upnp_session['status'])
    end

    def got_updated_service_list? upnp_session
      ['form', 'updated'].include?(upnp_session['status']) && !upnp_session['service_list'].empty?
    end

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

    # Return i18n service description
    def decide_which_description(service_list)
      desc_key_list = ["http", "streaming", "ftp", "telnet", "cifs", "mediaserver", "nzbget", "transmission",
        "owncloud_http", "owncloud_https", "afp", "gallery_http", "gallery_https", "wordpress_http", "wordpress_https",
         "php_mysql_phpmyadmin_http", "php_mysql_phpmyadmin_https"]

      service_list.each do |service|
        unless service["service_name"].empty?
          desc_key = service["service_name"].downcase.chomp(" ").gsub("-", "_").gsub("(", "_").gsub(")", "").gsub(" ", "_")
          service["description"] = I18n.t("upnp_description.#{desc_key}")   if desc_key_list.include?(desc_key)
        end
      end
      service_list
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

    def deleted_extra_key
      extra_keys = ["port", "update_result"]
      params[:service_list].each do |service|
        extra_keys.each do |key|
          service.delete(key) if service.has_key?(key)
        end
      end
    end

    # check the updated result and added the result to each
    def update_result service_list
      service_list.each do |service|
        result = "no_update"
        if settings_modified?(service)
            result = "failure" if (!service['error_code'].nil? && service['error_code'].length > 0)
            result = "success" if service['error_code'].blank?
        end
        service['update_result'] = result
      end
      service_list
    end

    def settings_modified? service
      is_service_status_modified?(service) || is_service_port_modified?(service)
    end

    def is_service_status_modified? service
      service['enabled'] != service['status']
    end

    def is_service_port_modified? service
      service['enabled'] && !service['origin_wan_port'].blank? && service['origin_wan_port'] != service['wan_port']
    end

    def update_permit
      params.permit(:service_list);
    end

    def get_device_info
      @device_ip = @device.session.hget(:ip)
    end

    def is_device_support?
      unless @device.find_module_list.include?(Upnp::MODULE_NAME)
        flash[:alert] = I18n.t('warnings.invalid_device')
        redirect_to :authenticated_root
      end
    end

    def get_error_msg error_code
      if UpnpSession.handling_error_code?(error_code)
        I18n.t("warnings.settings.upnp.error_code.num_" + error_code)
      else
        I18n.t("warnings.settings.upnp.not_found")
      end
    end
end
