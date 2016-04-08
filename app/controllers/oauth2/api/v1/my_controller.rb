class Oauth2::Api::V1::MyController < Oauth2::ApiController

  def info

    @user = current_resource_owner
    # @api_user = Api::User.find(doorkeeper_token.resource_owner_id)
    token = @user.create_token_set
    @account_token = token[:account_token]
    @authentication_token = token[:authentication_token]
    @time_out = @user.authentication_token_ttl
    # @xmpp_account = @api_user.apply_for_xmpp_account

    # render json: current_resource_owner.to_json
  end
end
