class Oauth2::AuthorizationsController < Doorkeeper::AuthorizationsController
  include ExceptionHandler
  include CheckUserConfirmation
  include Locale
  include OauthFlow
  include Theme

  layout 'application'

  prepend_before_action :store_sso_url, only: :new

  after_action :clear_sso_url

  private

    # 如果使用者未登入, 則將 sso_url 存入 cookies
    def store_sso_url
      session[:sso_url] = request.fullpath unless user_signed_in?
    end

    # 如果轉址至 redirect_uri, 則清空 cookies 中的 sso_url
    def clear_sso_url
      session.delete(:sso_url) if response.code == '302'
    end
end
