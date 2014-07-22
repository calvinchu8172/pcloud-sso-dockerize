class OauthController < ApplicationController

  def new
    @user = User.new
  end

  def confirm
    agreement = params[:user][:agreement]
    # Check provider and user
    identity = User.sign_up_omniauth(session["devise.omniauth_data"], current_user, agreement)
    if agreement
      # Sign In and redirect to root path
      sign_in_and_redirect identity.user
    else
      # Redirect to Sign in page, when user un-agreement the terms
      redirect_to new_user_session_path
    end
  end
end