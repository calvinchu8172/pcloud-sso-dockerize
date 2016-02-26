class Oauth2::Api::V1::MyController < Oauth2::ApiController

  def info
    binding.pry
    render json: current_resource_owner.to_json
  end
end
