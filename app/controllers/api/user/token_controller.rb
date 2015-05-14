# refer to http://fancypixel.github.io/blog/2015/01/28/react-plus-flux-backed-by-rails-api/
class Api::User::TokenController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!
  
  def create
    
    unless @user = Api::User.authenticate(token_params)
      return  render json: {code: '001', description: 'Invalid email or password.'}
    end

    return  render json: {code: '002', description: 'client have to confirm email account before continuing.'} unless @user.confirmed?
    
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
