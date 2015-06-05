# refer to http://fancypixel.github.io/blog/2015/01/28/react-plus-flux-backed-by-rails-api/
class Api::User::TokensController < Api::Base
  before_filter :authenticate_user_by_token!, only: :show

  def create
    
    @user = Api::User::Token.authenticate(token_params)
    unless @user.errors.empty?
      return  render json: @user.errors[:authenticate].first
    end
    
    @user.create_token
  end

  def show
    render json: {result: 'valid', timeout: current_token_user.authentication_token_ttl} if current_token_user
  end

  def update
    user = Api::User::Token.find_by_encoded_id(update_params[:cloud_id])
    logger.debug('update user:' + user.inspect)
    return render json: Api::User::INVALID_TOKEN_AUTHENTICATION unless user
    authentication_token = user.renew_authentication_token(update_params[:account_token])
    return render json: Api::User::INVALID_TOKEN_AUTHENTICATION unless authentication_token

    render json: {authentication_token: authentication_token}
  end

  def destroy
    user = Api::User::Token.find_by_encoded_id(update_params[:cloud_id])
    return render json: Api::User::INVALID_TOKEN_AUTHENTICATION if !user or !user.revoke_token(update_params[:account_token])
    render json: {result: "success"}
  end

  private 
    def token_params
      params.permit(:id, :password, :certificate_serial, :signature, :app_key, :os)
    end

    def update_params
      params.permit(:cloud_id, :account_token)
    end
end
