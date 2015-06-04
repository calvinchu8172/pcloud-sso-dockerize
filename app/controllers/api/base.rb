class Api::Base < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!

  protected
    def authenticate_user_by_token!
      @current_token_user = Api::User.find_by_encoded_id(authentication_params[:cloud_id])
      if @current_token_user.nil? or !@current_token_user.verify_authentication_token(authentication_params[:authentication_token])
        @current_token_user = false
        return render :json => Api::User::INVALID_TOKEN_AUTHENTICATION
      end
    end

    def current_token_user
      @current_token_user
    end

    def authentication_params
      params.permit(:cloud_id, :authentication_token)
    end
end