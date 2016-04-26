class Oauth2::Api::V1::MyController < Oauth2::ApiController

  def info

    @user = current_resource_owner
    token = @user.create_token_set
    @account_token = token[:account_token]
    @authentication_token = token[:authentication_token]
    @time_out = @user.authentication_token_ttl
    @user.uuid = params[:uuid] #將API打過來的uuid設給user model，然後才可生出下面的xmpp_account
    @xmpp_account = @user.apply_for_xmpp_account if params[:uuid]
    # render json: current_resource_owner.to_json
  end
end
