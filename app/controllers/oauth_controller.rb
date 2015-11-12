class OauthController < ApplicationController

  def new
    @user = User.new
  end

  def confirm
    agreement = params[:user][:agreement]
    if agreement == "1"
      # Check provider and user
      identity = User.sign_up_omniauth(session["devise.omniauth_data"], current_user, agreement)
      # Sign In and redirect to root path
      sign_in identity.user
      redirect_to session[:previous_url] || authenticated_root_path
      #記錄user註冊的os與oauth
      oauth = identity.provider
      identity.user.update(os: 'web', oauth: oauth) if identity.user.os.nil? || identity.user.oauth.nil?
      user = identity.user
      user_id = user.id
      sign_in_at = Time.now
      sign_out_at = nil
      sign_in_fail_at = nil
      sign_in_ip = user.current_sign_in_ip
      status = 1
      LoginLog.record_login_log(user_id, sign_in_at, sign_out_at, sign_in_fail_at, sign_in_ip, status)

    else
      # Redirect to Sign in page, when user un-agreement the terms
      flash[:notice] = I18n.t('activerecord.errors.messages.accepted')
      redirect_to '/oauth/new'
    end
  end
end
