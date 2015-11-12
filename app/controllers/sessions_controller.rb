class SessionsController < Devise::SessionsController

  # POST /resource/sign_in
  def create
    if omniauth_accout?(params[:user][:email])
      self.resource = resource_class.new(sign_in_params)
      flash[:alert] = I18n.t("devise.failure.already_oauth_account")
      redirect_to action: 'new'
    else
      super

      #登入登出，不修改user的os與oauth，user的os與oauth僅在註冊時寫入一次，這裡只記錄到login_log中
      user_id = current_user.id
      sign_in_at = Time.now
      sign_out_at = nil
      sign_in_fail_at = nil
      sign_in_ip = current_user.current_sign_in_ip
      os = 'web'
      oauth = 'email'
      LoginLog.record_login_log(user_id, sign_in_at, sign_out_at, sign_in_fail_at, sign_in_ip, os, oauth)
    end
  end

  # GET /resource/sign_out
  def destroy
    #登出時，若已經有登入的時間，則寫入登出時間便可，若之前無登入時間的紀錄，則記錄新的一筆登出時間
    user_id = current_user.id
    log_user = LoginLog.where(user_id: user_id).last
    if log_user.sign_out_at == nil && log_user.sign_in_at != nil
      log_user.update(sign_out_at: Time.now)
    else
      sign_in_at = nil
      sign_out_at = Time.now
      sign_in_fail_at = nil
      sign_in_ip = current_user.current_sign_in_ip
      os = 'web'
      oauth = 'email'
      LoginLog.record_login_log(user_id, sign_in_at, sign_out_at, sign_in_fail_at, sign_in_ip, os, oauth)
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
