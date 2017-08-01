class Oauth2::AuthorizationsController < Doorkeeper::AuthorizationsController
  include ExceptionHandler
  include CheckUserConfirmation
  include Locale
  include OauthFlow
  include Theme

  layout 'application'

  prepend_before_action :store_sso_url, only: :new

  before_action :set_locale, except: [:logout]
  before_action :store_sso_url, only: :new
  before_action :authenticate_resource_owner!, except: [:logout]

  after_action :clear_sso_url


  # for client logout with provider
  def logout
    # clear all scopes
    sign_out_all_scopes

    # set redirect_url => sign in page
    redirect_url = new_user_session_url
    # when url-querys has logout_redirect_uri & client_id parameters
    if params[:logout_redirect_uri] && params[:client_id]
      # load oauth application
      application = Doorkeeper::Application.find_by(uid: params[:client_id])
      # check logout_redirect_uri
      # 1. application of client_id exist
      # 2. application.logout_redirect_uri present
      # 3. application.logout_redirect_uri includes params[:logout_redirect_uri]
      # set redirect_url = params[:logout_redirect_uri]
      if application && application.logout_redirect_uri.present?
        if Doorkeeper::OAuth::Helpers::URIChecker.valid_for_authorization?(params[:logout_redirect_uri], application.logout_redirect_uri)
          redirect_url = params[:logout_redirect_uri]
        end
      elsif application && application.redirect_uri.blank?
        redirect_url = params[:logout_redirect_uri]
      end
    end
    redirect_to redirect_url
  end

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
