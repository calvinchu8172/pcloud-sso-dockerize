class Mods::V2::UpnpController < Mods::UpnpController
  before_action :check_session_available, :only => [:edit, :reload]

  # GET /2/upnp/:session_id/edit/
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

  # GET /2/upnp/reload/:id
  # reload the service list when updating services not all successfully
  def reload
    error_message = get_error_msg(@upnp_session['error_code'])
    path_ip = decide_which_path_ip(@upnp_session)

    service_list = []
    if @upnp_session['status'] == 'reload'
      # restart the session
      @upnp_session['status'] = 'start'
      @upnp.session.update(@upnp_session)
      push_to_queue("upnp_query", Mods::V2::Upnp::MODULE_VERSION)

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

  # GET /2/upnp/check/:id
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


  private

    def reload_step? upnp_session
      got_updated_service_list?(upnp_session) && upnp_session['status'] == 'form'
    end

    def got_updated_service_list? upnp_session
      ['form', 'updated'].include?(upnp_session['status']) && !upnp_session['service_list'].empty?
    end

    # check the updated result and added the result to each
    def update_result service_list
      service_list.each do |service|
        result = "no_update"
        service['is_service_port_modified'] = false
        if settings_modified?(service)
          service['is_service_port_modified'] = true if is_service_port_modified?(service)
          result = "failure"
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

end
