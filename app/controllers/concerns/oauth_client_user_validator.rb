module OauthClientUserValidator
  extend ActiveSupport::Concern

  included do

    before_action :check_user, only: [:create]

    def check_user

      if params["grant_type"] == 'refresh_token'
        refresh_token = params["refresh_token"]
        refresh_token = Doorkeeper::AccessToken.find_by(refresh_token: refresh_token)
        if refresh_token.nil? || !refresh_token.revoked_at.nil?
          render json: {error: 'Invalid refresh_token', error_description: 'The provided refresh token cannot be found or revoked'}, status: 401
          return
        end

        user = User.find(refresh_token.resource_owner_id)
        if user.nil?
          render json: {error: 'Invalid resource_owner of refresh_token', error_description: 'The owner of provided refresh token cannot be found'}, status: 400
          return
        end
      end

      if params["grant_type"] == 'authorization_code'
        code = params["code"]
        code = Doorkeeper::AccessGrant.find_by(token: code)
        if code.nil? || !code.revoked_at.nil?
          render json: {error: 'Invalid grant_code', error_description: 'The provided grant code cannot be found or revoked'}, status: 401
          return
        end

        user = User.find(code.resource_owner_id)
        if user.nil?
          render json: {error: 'Invalid resource_owner of grant_code', error_description: 'The owner of provided grant code cannot be found'}, status: 400
          return
        end
      end

      # 檢查使用者是否超過試用期
      if !user.confirmed? && !user.confirmation_valid?
        refresh_token.revoke if params["grant_type"] == 'refresh_token' && refresh_token.present?
        render json: { error: 'Expired user trial period', error_description: 'The user did not confirmed and the trial period has been expired 3 days' }, status: 400
        return
      end
    end

  end

end