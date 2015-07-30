class Mods::V1::UpnpController < Mods::UpnpController

  # GET /1/upnp/:session_id/edit/
  def edit
    error_message = get_error_msg(@upnp_session['error_code'])
    service_list = (@upnp_session['status'] == 'form' && !@upnp_session['service_list'].empty?)? JSON.parse(@upnp_session['service_list']) : {}
    service_list = decide_which_port(@upnp_session, service_list) unless service_list.empty?
    service_list = decide_which_description(service_list) unless service_list.empty?
    path_ip = decide_which_path_ip(@upnp_session)

    result = {:status => @upnp_session['status'],
              :device_id => @upnp_session['device_id'],
              :error_message => error_message,
              :service_list => service_list,
              :path_ip => path_ip,
              :id => @session_id
             }

    service_logger.note({edit_upnp: result})
    render :json => result
  end

  # GET /1/upnp/check/:id
  # for the polling from front end
  # it will check out session is still avaliable
  def check
    session_id = params[:id]
    upnp = UpnpSession.find(session_id)
    upnp_session = upnp.session.all

    error_message = get_error_msg(upnp_session['error_code'])
    path_ip = decide_which_path_ip upnp_session

    service_list = ((['form', 'updated'].include?(upnp_session['status'])) && !upnp_session['service_list'].empty?)? JSON.parse(upnp_session['service_list']) : {}
    service_list = decide_which_port(upnp_session, service_list) unless service_list.empty?
    service_list = decide_which_description(service_list) unless service_list.empty?
    service_list = update_result(service_list) unless service_list.empty?

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

end
