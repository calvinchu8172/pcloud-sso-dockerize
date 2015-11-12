# refer to http://fancypixel.github.io/blog/2015/01/28/react-plus-flux-backed-by-rails-api/
class Api::User::TokensController < Api::Base
  before_filter :authenticate_user_by_token!, only: :show

  def create

    @user = Api::User::Token.authenticate(token_params)

    if @user.errors.present? && @user.errors[:authenticate].present?

      user_id = @user.id
      sign_in_at = nil
      sign_out_at = nil
      sign_in_fail_at = Time.now
      sign_in_ip = @user.current_sign_in_ip
      os = LoginLog.check_os(token_params['os'])
      oauth = @user.oauth
      LoginLog.record_login_log(user_id, sign_in_at, sign_out_at, sign_in_fail_at, sign_in_ip, os, oauth)

      return  render json: @user.errors[:authenticate].first, :status => 400
    else

      user_id = @user.id
      sign_in_at = Time.now
      sign_out_at = nil
      sign_in_fail_at = nil
      sign_in_ip = @user.current_sign_in_ip
      os = LoginLog.check_os(token_params['os'])
      oauth = @user.oauth
      LoginLog.record_login_log(user_id, sign_in_at, sign_out_at, sign_in_fail_at, sign_in_ip, os, oauth)
    end
  end

  def show
    render json: {result: 'valid', timeout: current_token_user.authentication_token_ttl} if current_token_user
  end

  def update
    user = Api::User::Token.find_by_encoded_id(update_params[:cloud_id])
    return render json: Api::User::INVALID_TOKEN_AUTHENTICATION, :status => 400 unless user
    authentication_token = user.renew_authentication_token(update_params[:account_token])
    return render json: Api::User::INVALID_TOKEN_AUTHENTICATION, :status => 400 unless authentication_token

    render json: {authentication_token: authentication_token}
  end

  def destroy
    user = Api::User::Token.find_by_encoded_id(update_params[:cloud_id])

    # 假如之前有登入的資料的話，就修改登出時間，若沒有，新增一筆登出資料
    user_id = user.id
    log_user = LoginLog.where(user_id: user_id).last
    if log_user.sign_out_at == nil && log_user.sign_in_at != nil
      log_user.update(sign_out_at: Time.now)
    else
      sign_in_at = nil
      sign_out_at = Time.now
      sign_in_fail_at = nil
      sign_in_ip = current_user.current_sign_in_ip
      os = user.os
      oauth = user.oauth
      LoginLog.record_login_log(user_id, sign_in_at, sign_out_at, sign_in_fail_at, sign_in_ip, os, oauth)
    end

    return render json: Api::User::INVALID_TOKEN_AUTHENTICATION, :status => 400 if !user or !user.revoke_token(update_params[:account_token])
    render json: {result: "success"}
  end

  private
    def token_params
      params.permit(:id, :password, :certificate_serial, :signature, :app_key, :os, :uuid)
    end

    def update_params
      params.permit(:cloud_id, :account_token)
    end
end
