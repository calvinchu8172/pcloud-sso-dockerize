class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_devise_permitted_parameters, if: :devise_controller?
  before_filter :set_locale

  protected

    def configure_devise_permitted_parameters
      registration_params = [:first_name, :last_name, :email, :password, :password_confirmation, :gender, :mobile_number, :birthday, :language, :edm_accept, :agreement, :country]

      if params[:action] == 'update'
        devise_parameter_sanitizer.for(:accout_update) {
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
      if params[:locale] && I18n.available_locales.include?( params[:locale].to_sym) 
        session[:locale] = params[:locale]
      end
      I18n.locale = session[:locale] || I18n.default_locale

      # language select option
      @locale_options = { :English => 'en', 
                          :Italiano => 'it'}
    end
    # i18n setting - end
end
