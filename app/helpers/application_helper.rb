module ApplicationHelper
  def breadcrumb(page_flow)
    base_flow = false
    if page_flow.empty?
      base_flow
    else
      base_flow = page_flow.split(",")
    end
  end

  def page_title
    if Settings.environments.portal_domain.match("-beta.")
      "-beta"
    end
  end

  def get_ga_path
    if request.path == "/"
      ga_path = user_signed_in? ? '/personal/index' : '/users/sign_in'
    end
    ga_path || request.original_fullpath
  end

  def tutorial_path device, current_step = nil

    next_module = device.find_next_tutorial current_step

    url_params = {}
    url_params[:controller] = next_module != 'finished' ? next_module : 'personal'
    url_params[:action] = next_module != 'finished' ? 'show' : 'index'
    url_params[:id] = device.escaped_encrypted_id unless next_module == 'finished'

    url_for url_params
  end

  def confirmation_expire_time_string(timezone = nil)
    timezone = Time.zone.name if timezone.nil?
    current_user.confirmation_expire_time.in_time_zone(timezone).strftime("%Y-%m-%d %H:%M %Z")
  end
end
