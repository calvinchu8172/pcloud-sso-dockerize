class Oauth2::AuthorizedApplicationsController < Doorkeeper::AuthorizedApplicationsController
  include CheckUserConfirmation
  include Locale

  layout 'rwd'

end
