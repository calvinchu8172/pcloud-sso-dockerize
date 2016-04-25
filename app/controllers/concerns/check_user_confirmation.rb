module CheckUserConfirmation
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :check_skip_confirm
    before_action :check_user_confirmation_expire

    # http_basic_authenticate_with :name => Settings.oauth_applications.account, :password => Settings.oauth_applications.password

      def check_user_confirmation_expire

        return if current_user.nil?

        # redirect_to new_user_confirmation_path if ( !current_user.confirmed? && !current_user.confirmation_valid? )
        if !current_user.confirmed? && !!warden.session['skip_confirm'] == false
          store_location_for(current_user, request.fullpath)
          redirect_to new_user_confirmation_path
        end
      end

      def check_skip_confirm
        if params['skip_confirm'] == 'true'
          warden.session['skip_confirm'] = Time.now.to_i
        end
      end

  end
end