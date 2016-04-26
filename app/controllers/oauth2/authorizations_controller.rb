class Oauth2::AuthorizationsController < Doorkeeper::AuthorizationsController
  include CheckUserConfirmation
  include Locale

  layout 'rwd'

end
