module OauthClientUserValidator
  extend ActiveSupport::Concern

  included do

    before_action :check_user, only: [:create]

    def check_user
      # binding.pry
      refresh_token = params["refresh_token"]
      refresh_token = Doorkeeper::AccessToken.find_by(refresh_token: refresh_token)
      if refresh_token.nil? || !refresh_token.revoked_at.nil?
        render json: {error: 'Invalid refresh_token', error_description: 'The provided refresh token cannot be found or revoked'}, :status => 401
        return
      end

      user = User.find(refresh_token.resource_owner_id)
      if user.nil?
        render json: {error: 'Invalid resource_owner of refresh_token', error_description: 'The owner of provided refresh token cannot be foound'}, :status => 400
        return
      end

      if !user.confirmed?
        if !user.confirmation_valid?
          render json: {error: 'Expired user trial period', error_description: 'The user did not confirmed and the trial period has been expired 3 days'}, :status => 400
          return
        end
      end

    end

  end

end