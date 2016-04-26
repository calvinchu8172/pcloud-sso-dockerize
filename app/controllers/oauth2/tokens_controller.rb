class Oauth2::TokensController < Doorkeeper::TokensController
  include AbstractController::Callbacks
  include OauthClientUserValidator

end
