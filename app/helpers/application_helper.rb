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

  def confirmation_expire_time_string(timezone = Time.zone)
    timezone ||= "UTC"
    current_user.confirmation_expire_time.in_time_zone(Time.zone).strftime("%Y-%m-%d %H:%M %Z")
  end

  def show_unverified_button
    unless current_user.confirmed? || params["controller"] == "confirmations"
      link_to I18n.t("labels.unverified"), new_user_confirmation_path, class: "unverified"
    end
  end

  def confirmed_or_valid_unconfirmed_access?
    current_user.confirmed? || current_user.confirmation_valid?
  end

end
