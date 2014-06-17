class ConfirmationsController < Devise::ConfirmationsController

  protected

  def after_confirmation_path_for(resource_name, resource)
    hint_signup_path
    if signed_in?(resource_name)
      hint_signup_path(resource)
    else
      new_session_path(resource_name)
    end
  end
end