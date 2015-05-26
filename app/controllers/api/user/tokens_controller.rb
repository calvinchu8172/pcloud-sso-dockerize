# refer to http://fancypixel.github.io/blog/2015/01/28/react-plus-flux-backed-by-rails-api/
class Api::User::TokensController < Api::Base
  
  def create
    
    @user = Api::User::Token.authenticate(token_params)
    unless @user.errors.empty?
      return  render json: @user.errors[:authenticate].first
    end
    
    @user.app_info.bulk_set(token_params.slice(:app_key, :os)) if !token_params[:app_key].blank? and !token_params[:os].blank? and ['1', '2'].include?(token_params[:os])
    @user.create_token_set
  end

  def show

  end

  def update

  end

  def destroy
  end

  private 

    def token_params
      params.permit(:email, :password, :app_key, :os)
    end
end
