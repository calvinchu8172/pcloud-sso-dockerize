class Oauth2::AuthorizationsController < Doorkeeper::AuthorizationsController
  include CheckUserConfirmation
  include Locale
  include OauthFlow

  layout 'rwd'

end
