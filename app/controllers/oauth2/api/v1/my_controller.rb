class Oauth2::Api::V1::MyController < Oauth2::ApiController

  def info
    render json: current_resource_owner.to_json
  end
end
