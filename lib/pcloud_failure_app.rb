class PcloudFailureApp < Devise::FailureApp
  def redirect
    store_location!
    if is_flashing_format?
      if flash[:timedout] && flash[:alert]
        flash.keep(:timedout)
        flash[:alert] = i18n_message(:timeout)
      else
        flash[:alert] = i18n_message
      end
    end
    redirect_to redirect_url
  end
end
