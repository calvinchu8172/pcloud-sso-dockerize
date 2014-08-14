class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_devise_permitted_parameters, if: :devise_controller?
  before_filter :set_locale
  after_action :store_location

  protected

    def configure_devise_permitted_parameters
      registration_params = [:first_name, :middle_name, :last_name, :display_name, :email, :password, :password_confirmation, :gender, :mobile_number, :birthday, :language, :edm_accept, :agreement, :country]

      if params[:action] == 'update'
        devise_parameter_sanitizer.for(:account_update) {
        	|u| u.permit(registration_params << :current_password)
        }
      elsif params[:action] == 'create'
        devise_parameter_sanitizer.for(:sign_up) {
        	|u| u.permit(registration_params)
        }
      end
    end

    # i18n setting
    def set_locale
      if user_signed_in?
        session[:locale] = I18n.available_locales.include?( current_user.language.to_sym) ? current_user.language.to_sym : false
      else
        if params[:locale] && I18n.available_locales.include?( params[:locale].to_sym)
          session[:locale] = params[:locale]
        end
      end
      I18n.locale = session[:locale] || I18n.default_locale

      # language select option
      @locale_options = { :English => 'en'}
    end
    # i18n setting - end

    # Redirect back to current page after sign in
    def store_location
      return unless request.get?
      if(request.path != "/users/sign_in" &&
         request.path != "/users/sign_up" &&
         request.path != "/users/password/new" &&
         request.path != "/users/password/edit" &&
         request.path != "/users/confirmation" &&
         request.path != "/users/sign_out" &&
         !request.xhr? && # don't store ajax calls
         !request.accept.match(/json/)) # don't store json calls
        session[:previous_url] = request.fullpath
      end
    end

    def device_paired_with?
      device_id = params[:id]
      unless(paired?(device_id, current_user.id))
        flash[:alert] = "invalid device"
        redirect_to :root
      end
    end

    def paired?(device_id, user_id)
      Pairing.enabled.exists?({:device_id => device_id, :user_id => user_id})
    end
end
