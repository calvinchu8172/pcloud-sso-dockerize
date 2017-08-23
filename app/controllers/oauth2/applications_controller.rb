class Oauth2::ApplicationsController < Doorkeeper::ApplicationsController
  include CheckUserConfirmation
  include HttpBasicAuthenticate
  include Locale
  include Theme

  before_action :authenticate_resource_owner!

  private

  # application strong parameter
  def application_params
    params.require(:doorkeeper_application).permit(
      :name, :redirect_uri, :scopes, :logout_redirect_uri
    )
  end

end
