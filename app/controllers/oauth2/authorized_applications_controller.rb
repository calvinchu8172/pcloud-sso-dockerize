class Oauth2::AuthorizedApplicationsController < Doorkeeper::AuthorizedApplicationsController
	include ExceptionHandler
  include CheckUserConfirmation
  include Locale
  include Theme

  # layout 'rwd'
  layout 'sso'


end
