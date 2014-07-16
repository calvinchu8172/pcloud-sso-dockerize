class OauthController < ApplicationController
  before_action :check_provider
  def new
    @user = User.new
  end

  def confirm
    agreement = params[:user][:agreement]
    email = @need_email ? params[:email] : session["devise.omniauth_data"]["info"]["email"]
    # Check provider and user
    identity = User.sign_up_omniauth(session["devise.omniauth_data"], current_user, agreement, email)
    if agreement

      # Send confirmation email, when user provide email
      if @need_email
        redirect_to hint_confirm_path
      else
      # Sign In and redirect to root path
        sign_in_and_redirect identity.user
      end
    else
      # Redirect to Sign in page, when user un-agreement the terms
      redirect_to new_user_session_path
    end
  end

  private
    # we need to ask user's email, when provider is twitter
    def check_provider
      if session["devise.omniauth_data"]["provider"] == "twitter"
        @need_email = true
      end
    end
end