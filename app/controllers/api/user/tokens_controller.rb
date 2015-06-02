# refer to http://fancypixel.github.io/blog/2015/01/28/react-plus-flux-backed-by-rails-api/
class Api::User::TokensController < Api::Base
  before_filter :authenticate_user_by_token!, only: :show

  def create
    
    @user = Api::User::Token.authenticate(token_params)
    unless @user.errors.empty?
      return  render json: @user.errors[:authenticate].first
    end
    
    @user.app_info.bulk_set(token_params.slice(:app_key, :os)) if !token_params[:app_key].blank? and !token_params[:os].blank? and ['1', '2'].include?(token_params[:os])
    @user.create_token_set
  end

  def show
    render json: {result: 'valid', timeout: current_token_user.authentication_token_ttl} if current_token_user
  end

  def update

  end

  def destroy
    user = Api::User::Token.find_by_encoded_id(destroy_params[:cloud_id])
    return render json: Api::User::INVALID_TOKEN_AUTHENTICATION if !user or !user.revoke_token(destroy_params[:account_token])
    render json: {result: "success"}
  end

  private 

    def token_params
      params.permit(:email, :password, :certificate_serial, :signature, :app_key, :os)
    end

    def destroy_params
      params.permit(:cloud_id, :account_token)
    end
end
