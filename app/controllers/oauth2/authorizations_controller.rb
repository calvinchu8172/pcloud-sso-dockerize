class Oauth2::AuthorizationsController < Doorkeeper::AuthorizationsController
	include ExceptionHandler
  include CheckUserConfirmation
  include Locale
  include OauthFlow

  layout 'rwd'

end
