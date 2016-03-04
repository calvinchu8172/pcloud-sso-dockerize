class Oauth2::ApiController < ActionController::API

  before_action :doorkeeper_authorize!
  # before_action :setup_mdc

  private

    # 若沒加上這個 gem 'browser-timezone-rails' 會出現 NameError (undefined local variable or method `cookies'
    def set_time_zone(&action)
      Time.use_zone(Time.zone, &action)
    end

    # def setup_mdc
      # Logging.mdc['from'] = request.remote_ip
    # end

    def current_resource_owner
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end
end
