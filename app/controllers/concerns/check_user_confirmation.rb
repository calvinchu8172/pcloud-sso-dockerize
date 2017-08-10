module CheckUserConfirmation
  extend ActiveSupport::Concern

  included do
    # before_action :authenticate_user!, except: [:logout]
    before_action :check_skip_confirm
    before_action :check_user_confirmation_expire

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