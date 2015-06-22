# 同步並更新 package 相關設定
# package 設定流程的狀態如下
# * start: 向Device 要求目前的package 目前設定
# * form: Device 回傳目前的設定，讓使用者填寫
# * submit: 從Portal 這傳送使用者異動結果給Device
# * updated: 更新成功
# * failure: device 回傳失敗訊息
# * cancel: 過程中，隨時可以取消對該裝置的設定程序
# * timeout: 在同步過程中，device在時間內未對配對流程確認，則判斷為timout
class PackageController < ApplicationController
  before_action :authenticate_user!
  before_action :device_paired_with?, :only => :show
  #before_action :deleted_extra_key, :only => :update
  before_action :service_list_to_json, :only => :update
  before_action :is_device_support?, :only => :show

  # GET /package/show/:device_encrypted_id
  # 初始化package Session 並向Device 同步UPnP 設定資訊
  def show
    get_device_info
    @session = {:user_id => current_user.id,
                :device_id => @device.id,
                :status => 'start'}

    @package = PackageSession.create
    @package.session.bulk_set(@session)

    push_to_queue "package_query"
    @session[:id] = @package.id

    service_logger.note({start_package: @session})
  end

  # GET /upnp/:session_id/edit/
  #
  def edit

    session_id = params[:id]
    package_session = PackageSession.find(session_id).session.all
    render :json => {:result => 'timeout'} and return if package_session.empty?

    error_message = get_error_msg(package_session['error_code'])
    package_list = (package_session['status'] == 'form' && !package_session['package_list'].empty?)? JSON.parse(package_session['package_list']) : {}
    #package_list = decide_which_description(package_list) unless package_list.empty?
    #path_ip = decide_which_path_ip package_session

    result = {:status => package_session['status'],
              :device_id => package_session['device_id'],
              :error_message => error_message,
              :package_list => package_list,
              :requires => package_session['requires'],
              :version => package_session['version'],
              :id => session_id
             }

    service_logger.note({edit_package: result})
    render :json => result
  end

  def update
    @package = PackageSession.find(params[:id])
    settings = update_permit.merge({:status => :submit})
    result = @package.session.update(settings);

    push_to_queue "package_submit" if result
    service_logger.note({update_package: settings})
    render :json => {:result => result}.to_json
  end

  # GET /pairing/check/:id
  # for the polling from front end
  # it will check out session is still avaliable
  def check

    session_id = params[:id]
    package = PackageSession.find(session_id)
    package_session = package.session.all

    error_message = get_error_msg(package_session['error_code'])
    #path_ip = decide_which_path_ip package_session

    package_list = ((package_session['status'] == 'form' || package_session['status'] == 'updated') && !package_session['package_list'].empty?)? JSON.parse(package_session['package_list']) : {}
    #service_list = decide_which_description(service_list) unless service_list.empty?
    package_list = update_result(package_list) unless package_list.empty?

    result = {:status => package_session['status'],
              :device_id => package_session['device_id'],
              :error_message => error_message,
              :package_list => package_list,
              :requires => package_session['requires'],
              :version => package_session['version'],
              :id => session_id
             }

    service_logger.note({failure_package: result}) if package_session['status'] == 'failure' || package_session['status'] == 'timeout'
    render :json => result
  end

  # GET /upnp/cancel/:id
  # cancel upnp setting process
  def cancel
    session_id = params[:id]
    @package = PackageSession.find(session_id)
    session = @package.session.all
    unless session.empty?
      session['status'] = "cancel"
      @package.session.update(session)
      push_to_queue_cancel("get_package_service", @package.id)
    end

    service_logger.note({cancel_package: session})
    redirect_to :authenticated_root
  end

  private

  def same_subnet? device_ip
    request.remote_ip == device_ip
  end



  def decide_which_path_ip package_session
    device = Device.find package_session['device_id']
    same_subnet?(device.session.hget('ip')) ? package_session['lan_ip'] : device.session.hget('ip')
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
    params[:package_list] = params[:package_list].to_json
  end

  def push_to_queue(job)
    data = {:job => job, :session_id => @package.id}
    #sqs = AWS::SQS.new
    #queue = sqs.queues.named(Settings.environments.sqs.name)
    #queue.send_message(data.to_json)
  end

  def deleted_extra_key
    extra_keys = ["port", "update_result"]
    params[:package_list].each do |package|
      extra_keys.each do |key|
        service.delete(key) if service.has_key?(key)
      end
    end
  end

  # check the updated result and added the result to each
  def update_result package_list
    package_list.each do |package|
      result = "no_update"

      if package['error_code'] && package['enabled'] != package['status']
        if package['error_code'].length == 0
          result = "success"
        else
          result = "failure"
        end
      end
      package['update_result'] = result
    end
    package_list
  end

  def update_permit
    params.permit(:package_list);
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
    if PackageSession.handling_error_code?(error_code)
      I18n.t("warnings.settings.package.error_code.num_" + error_code)
    else
      I18n.t("warnings.settings.package.not_found")
    end
  end
end
