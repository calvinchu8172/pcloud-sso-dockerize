class Oauth2::AuthorizationsController < Doorkeeper::AuthorizationsController
  include ExceptionHandler
  include CheckUserConfirmation
  include Locale
  include OauthFlow
  include Theme

  layout 'application'

  prepend_before_action :theme, :set_locale

end
