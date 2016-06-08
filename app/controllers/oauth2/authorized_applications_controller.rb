class Oauth2::AuthorizedApplicationsController < Doorkeeper::AuthorizedApplicationsController
	include ExceptionHandler
  include CheckUserConfirmation
  include Locale

  layout 'rwd'

end
