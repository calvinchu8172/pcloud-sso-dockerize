class SessionsController < Devise::SessionsController

  # POST /resource/sign_in
  def create
    if omniauth_accout?(params[:user][:email])
      self.resource = resource_class.new(sign_in_params)
      flash[:alert] = I18n.t("devise.failure.already_oauth_account")
      redirect_to action: 'new'
    else
      super

      user_id = current_user.id
      sign_in_at = Time.now
      sign_out_at = nil
      sign_in_fail_at = nil
      sign_in_ip = current_user.current_sign_in_ip
      status = 1
      LoginLog.record_login_log(user_id, sign_in_at, sign_out_at, sign_in_fail_at, sign_in_ip, status)
    end
  end

  # GET /resource/sign_out
  def destroy

    user_id = current_user.id
    userx = LoginLog.where(user_id: user_id).last
    if userx.sign_out_at == nil && userx.sign_in_at != nil
      userx.update(sign_out_at: Time.now)
    else
      sign_in_at = nil
      sign_out_at = Time.now
      sign_in_fail_at = nil
      sign_in_ip = current_user.current_sign_in_ip
      status = 1
      LoginLog.record_login_log(user_id, sign_in_at, sign_out_at, sign_in_fail_at, sign_in_ip, status)
    end

    super
  end

  private
  def omniauth_accout?(user_email)
    oauth = false
    user = User.find_by_email(user_email)
    if !user.nil?
      oauth = true if user.confirmation_token.nil?
    end
    oauth
  end

end
