class OauthController < ApplicationController

  def new
    @user = User.new
  end

  def confirm
    agreement = params[:user][:agreement]
    if agreement == 1
      # Check provider and user
      identity = User.sign_up_omniauth(session["devise.omniauth_data"], current_user, agreement)
      # Sign In and redirect to root path
      sign_in identity.user
      redirect_to authenticated_root_path
    else
      # Redirect to Sign in page, when user un-agreement the terms
      flash[:notice] = I18n.t('activerecord.errors.messages.accepted')
      redirect_to '/oauth/new'
    end
  end
end