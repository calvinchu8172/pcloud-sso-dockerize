
# 同步並更新 UPnP 相關設定
# UPnP 設定流程的狀態如下
# * start: 向Device 要求目前的UPnP 目前設定
# * form: Device 回傳目前的設定，讓使用者填寫
# * submit: 從Portal 這傳送使用者異動結果給Device
# * updated: 更新成功
# * failure: device 回傳失敗訊息
# * cancel: 過程中，隨時可以取消對該裝置的配對程序
# * timeout: 在同步過程中，device在時間內未對配對流程確認，則判斷為timout
class Mods::UpnpController < ApplicationController
  before_action :authenticate_user!
  before_action :device_paired_with?, :only => :show
  before_action :is_device_support?, :only => :show
  before_action :deleted_extra_key, :only => :update
  before_action :service_list_to_json, :only => :update
  before_action :check_session_available, :only => :edit

  # GET /{module_version}/upnp/:device_encoded_id
  # 初始化 UPnP Session 並向Device 同步UPnP 設定資訊
  def show
    get_device_info
    @session = { :user_id => current_user.id, :device_id => @device.id, :status => 'start' }

    @upnp = UpnpSession.create
    @upnp.session.bulk_set(@session)

    push_to_queue("upnp_query", @device.get_module_version('upnp'))
    @session[:id] = @upnp.id

    service_logger.note({start_upnp: @session})

    @random_port_max = Settings.environments.upnp.random_port_max
    @random_port_min = Settings.environments.upnp.random_port_min
  end

  #PUT /{moduel_version}/upnp/:device_encoded_id
  def update
    @upnp = UpnpSession.find(params[:id])
    settings = update_permit.merge({:status => :submit})
    result = @upnp.session.update(settings);

    upnp_session = @upnp.session.all
    device = Device.find(upnp_session['device_id'])
    push_to_queue("upnp_submit", device.get_module_version('upnp')) if result

    service_logger.note({edit_upnp: settings})
    render :json => {:result => result}.to_json
  end

  # GET /{module_version}/upnp/cancel/:id
  def cancel
    session_id = params[:id]
    @upnp = UpnpSession.find(session_id)
    session = @upnp.session.all
    unless session.empty?
      session['status'] = "cancel"
      @upnp.session.update(session)
      AwsService.push_to_queue_cancel("get_upnp_service", @upnp.id)
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

    # 判斷是否與 device 在相同網段下
    def same_subnet? device_ip
      request.remote_ip == device_ip
    end

    # 根據使用者的 ip 與 device 的 ip 比對，若處在相同的網段，
    # 則使用 lan_port，其餘的情況使用 wan_port
    def decide_which_port(upnp_session, service_list)
      device = Device.find upnp_session['device_id']
      port = same_subnet?(device.session.hget('ip')) ? "lan_port" : "wan_port"
      service_list.each do |service|
        service['port'] = service[port]
      end
      service_list
    end

    # 若與 device 在相同的網段，則使用 lan_ip 當路徑，
    # 其餘則使用 device 的 ip 當路徑
    def decide_which_path_ip upnp_session
      device = Device.find upnp_session['device_id']
      same_subnet?(device.session.hget('ip')) ? upnp_session['lan_ip'] : device.session.hget('ip')
    end

    def service_list_to_json
      params[:service_list] = params[:service_list].to_json
    end

    def push_to_queue(job, module_version)
      data = {:job => job, :session_id => @upnp.id, :module_version => module_version}
      AwsService.send_message_to_queue(data)
    end

    def deleted_extra_key
      extra_keys = ["port", "update_result"]
      params[:service_list].each do |service|
        extra_keys.each do |key|
          service.delete(key) if service.has_key?(key)
        end
      end
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

    # check the updated result and added the result to each
    def update_result service_list
      service_list.each do |service|
        result = "no_update"

        if service['error_code'] && service['enabled'] != service['status']
          if service['error_code'].length == 0
            result = "success"
          else
            result = "failure"
          end
        end
        service['update_result'] = result
      end
      service_list
    end

    # 判斷 device 的 module 是否支援 upnp
    def is_device_support?
      path = request.original_fullpath
      module_version = path[/\d+/]
      unless @device.find_module_list.include?(Mods::Upnp::MODULE_NAME)
        flash[:alert] = I18n.t('warnings.invalid_device')
        redirect_to :authenticated_root
        return
      end
      unless @device.get_module_version(Mods::Upnp::MODULE_NAME).to_s == module_version.to_s
        flash[:alert] = I18n.t('warnings.invalid_device')
        redirect_to :authenticated_root
        return
      end
    end

    def update_permit
      params.permit(:service_list);
    end

    def get_device_info
      @device_ip = @device.session.hget(:ip)
    end

    def failure_step? upnp_session
      ['failure', 'timeout'].include?(upnp_session['status'])
    end

    def get_error_msg error_code
      if UpnpSession.handling_error_code?(error_code)
        I18n.t("warnings.settings.upnp.error_code.num_" + error_code)
      else
        I18n.t("warnings.settings.upnp.not_found")
      end
    end
end