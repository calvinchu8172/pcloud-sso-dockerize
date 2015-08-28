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
    package_list = decide_enable(package_list) unless package_list.empty?
    #path_ip = decide_which_path_ip package_session
    dependency_list = gen_dependency_list session_id
    result = {:status => package_session['status'],
              :device_id => package_session['device_id'],
              :error_message => error_message,
              :package_list => package_list,
              :requires => package_session['requires'],
              :version => package_session['version'],
              :id => session_id,
              :dependency_list => dependency_list
             }

    service_logger.note({edit_package: result})


    render :json => result
  end

  def update
    @package = PackageSession.find(params[:id])
    current_settings = update_permit.merge({:status => :submit})
    dependency_list = gen_dependency_list params[:id]
    current_settings = check_enable( current_settings , dependency_list )
    #puts current_settings
    result = @package.session.update(current_settings);
    push_to_queue "package_submit" if result
    service_logger.note({update_package: current_settings})
    render :json => {:result => result}.to_json
  end

  # GET /pairing/check/:id
  # for the polling from front end
  # it will check out session is still avaliable
  def check

    session_id = params[:id]
    @package = PackageSession.find(session_id)
    package_session = @package.session.all

    error_message = get_error_msg(package_session['error_code'])
    #path_ip = decide_which_path_ip package_session

    package_list = !package_session['package_list'].empty? ? JSON.parse(package_session['package_list']) : {}
    #package_list = decide_enable(package_list) unless package_list.empty?
    if (package_session['status'] == 'updated')
      package_list = update_result(package_list) unless package_list.empty?
    end

    #dependency_list = gen_dependency_list session_id unless package_list.empty?
    #puts package_list
    result = {:status => package_session['status'],
              :device_id => package_session['device_id'],
              :error_message => I18n.t("warnings.settings.package.failure"),
              :package_list => package_list,
              :requires => package_session['requires'],
              :version => package_session['version'],
              :id => session_id,
             }
    package_session['package_list'] = package_list.to_json
    @package.session.update( package_session );

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
      AwsService.push_to_queue_cancel("get_package_service", @package.id)
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
  def decide_enable(package_list)
    package_list.each do |package|
      unless package["package_name"].blank?
        package["enabled"] = package["status"]
      end
    end
    desc_key_list = ["gallery", "googledriveclient", "squeezecenter", "memopal", "nfs", "nzbget", "php-mysql-phpmyadmin", "tftp",
        "transmission", "wordpress", "myzyxelcloud-agent", "owncloud", "pyload"]

    package_list.each do |package|
      unless package["package_name"].empty?
        desc_key = package["package_name"].downcase
        package["description"] = I18n.t("labels.settings.package.description.#{desc_key}")   if desc_key_list.include?(desc_key)
      end
    end
    package_list
  end

  def service_list_to_json
    params[:package_list] = params[:package_list].to_json
  end

  def push_to_queue(job)
    data = {:job => job, :session_id => @package.id}
    AwsService.send_message_to_queue(data)
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

      if package['enabled'] != package['status']
        if package['error_code'].length == 0
          result = "success"
          package['status'] = package['enabled']
        else
          result = "failure"
          package['enabled'] = package['status']
        end
      end
      package['update_result'] = result
    end
    package_list
  end

  def gen_dependency_list session_id
    package_old = PackageSession.find(session_id)
    enable_list = Hash.new
    disable_list = Hash.new
    dependency_list = Hash.new
    package_session = package_old.session.all

    begin
      result = JSON.parse(package_session['package_list'])
    rescue
      result = {}
    end

    package_list_current = package_session['package_list'] ? result : {}
    package_list_current.each do |package|
      if package['requires']
        if package['requires'][0] != nil
          package_name = package['package_name']
          package['requires'].each do | requires |
            disable_list[ requires ] = Array.new if !disable_list[ requires ]
            disable_list[ requires ] << package_name
            enable_list [ package_name ] = Array.new if !enable_list [ package_name ]
            enable_list [ package_name ] << requires
          end
        end
      end
    end
    dependency_list['enable_list'] = enable_list
    dependency_list['disable_list'] = disable_list
    dependency_list
  end

  def update_permit
    params.permit(:package_list);
  end

  def search_dependency ( package_name, list, enabled )
    final_list = Hash.new
    list.each {|key, requires|
      if key == package_name
        requires.each{|requires_name|
          final_list[requires_name] = {:enabled => enabled}
          final_list.merge( search_dependency( requires_name , list , enabled ) )
        }
      end
     }
    final_list
  end

  def check_enable (settings , dependency_list)
    final_enable_list = Hash.new
    final_disable_list = Hash.new
    package_list = JSON.parse( settings['package_list'] )
    package_list.each do | package_upload |
      if package_upload['enabled'] != package_upload['status']
        #puts 'package_name : ' + package_upload['package_name'] + '--' + package_upload['enabled'].to_s + '--' + package_upload['status'].to_s
        if ( package_upload['enabled'] == false )
          final_disable_list[package_upload['package_name']] = {:enabled => false}
          final_disable_list.merge( search_dependency( package_upload['package_name'] , dependency_list['disable_list'] , false ) )
        else
          final_enable_list[package_upload['package_name']]= {:enabled => true}
          final_enable_list.merge( search_dependency( package_upload['package_name'] , dependency_list['enable_list'] , true ) )
        end
      end
    end
    final_list = final_disable_list.merge( final_enable_list )
    final_list.each{|package_name, data|
      package_list.each{|package_current|
        if(package_current['package_name'] == package_name)
          package_current['enabled'] = data[:enabled]
        end
        package_current['error_code'] = ''
      }
    }
    settings['package_list'] =  package_list.to_json
    settings
  end

  def get_device_info
    @device_ip = @device.session.hget(:ip)
  end

  def is_device_support?
    unless @device.find_module_list.include?(Package::MODULE_NAME)
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
