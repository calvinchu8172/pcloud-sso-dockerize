class OauthController < ApplicationController

  def new
    @user = User.new
  end

  def confirm
    agreement = params[:user][:agreement]

    if agreement
      # Check provider and user
      identity = User.sign_up_omniauth(session["devise.omniauth_data"], current_user, agreement)
      # Sign In and redirect to root path
      sign_in identity.user
      redirect_to authenticated_root_path
    else
      # Redirect to Sign in page, when user un-agreement the terms
      redirect_to new_user_session_path
    end
  end
end