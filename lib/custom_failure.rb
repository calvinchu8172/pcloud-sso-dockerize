# Override Devise::FailureApp

class CustomFailure < Devise::FailureApp
  def redirect_url
    if warden_message == :unconfirmed
      new_user_confirmation_path
    else
      super
    end
  end

  # You need to override respond to eliminate recall
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end