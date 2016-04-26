class SessionsController < Devise::SessionsController

  layout 'rwd'

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
    # 假如之前沒有登入資料，就新增一筆登出資料，假如有登入的資料的話，就修改登出時間
    user_id = current_user.id
    log_user = LoginLog.where(user_id: user_id).last
    if log_user == nil
      sign_in_at = nil
      sign_out_at = Time.now
      sign_in_fail_at = nil
      sign_in_ip = current_user.current_sign_in_ip
      os = 'web'
      oauth = 'email'
      LoginLog.record_login_log(user_id, sign_in_at, sign_out_at, sign_in_fail_at, sign_in_ip, os, oauth)
    else
      log_user.update(sign_out_at: Time.now)
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
