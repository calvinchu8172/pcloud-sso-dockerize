class Api::Base < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!

  protected

    def authenticate_user_by_token_include_unconfirmed!
      unless authenticate_token!
        return render :json => Api::User::INVALID_TOKEN_AUTHENTICATION, :status => 400
      end
    end

    def authenticate_user_by_token!
      unless authenticate_token!
        return render :json => Api::User::INVALID_TOKEN_AUTHENTICATION, :status => 400
      end
      unless @current_token_user.confirmed_in_grace_period?
        return render :json => Api::User::INVALID_TOKEN_AUTHENTICATION, :status => 400
      end
    end

    def current_token_user
      @current_token_user
    end

    def authentication_params
      params.permit(:cloud_id, :authentication_token)
    end

    def oauth_access_token
      oauth_access_token = Doorkeeper::AccessToken.find_by(token: authentication_params[:authentication_token])
    end

  private
    def authenticate_token!
      @current_token_user = Api::User.find_by_encoded_id(authentication_params[:cloud_id])

      if @current_token_user.nil?
        return false
      end

      unless @current_token_user.verify_authentication_token(authentication_params[:authentication_token])
        unless verify_oauth_access_token(@current_token_user.id, authentication_params[:authentication_token])
          return false
        end
      end

      return true
    end

    def verify_oauth_access_token(user_id, authentication_token)
      # oauth_access_token = Doorkeeper::AccessToken.find_by(token: authentication_token)
      if oauth_access_token.nil?
        return false
      end

      if oauth_access_token.resource_owner_id != user_id
        return false
      end

      if oauth_access_token.revoked_at.nil?
        if oauth_access_token_expired?(oauth_access_token.created_at, oauth_access_token.expires_in)
          return false
        end
        return true
      end
    end

    def oauth_access_token_expired?(oauth_access_token_created_at, oauth_access_token_expires_in)
      if Time.now.to_i - oauth_access_token_created_at.to_i > oauth_access_token_expires_in
        return true
      else
        return false
      end
    end
end