# class Oauth2::ApiController < ActionController::API
class Oauth2::ApiController < ActionController::Base

  before_action :doorkeeper_authorize!
  # before_action :setup_mdc
  # binding.pry

  private

    # def setup_mdc
      # Logging.mdc['from'] = request.remote_ip
    # end

    def current_resource_owner
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end
end
