class Oauth2::ApiController < ActionController::API
  include ActionController::ImplicitRender #讓ActionController::API可以用jbuilder
  include ApiErrors

  before_action :doorkeeper_authorize!
  # before_action :setup_mdc

  private

    # 若沒加上這個，則 gem 'browser-timezone-rails' 會出現 NameError (undefined local variable or method `cookies'
    def set_time_zone(&action)
      Time.use_zone(Time.zone, &action)
    end

    # def setup_mdc
      # Logging.mdc['from'] = request.remote_ip
    # end

    def current_resource_owner
      # User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      ::Api::User::Token.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def doorkeeper_unauthorized_render_options(error: nil)
      if doorkeeper_token.nil?
        { :json => { code: "401.0", message: error("401.0") } }
      elsif doorkeeper_token.revoked?
        { :json => { code: "401.0", message: error("401.0") } }
      elsif doorkeeper_token.expired?
        { :json => { code: "401.1", message: error("401.1") } }
      else
        { :json => { code: "401.0", message: error("401.0") } }
      end
    end
end
