class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_devise_permitted_parameters, if: :devise_controller?
  before_filter :set_locale
  before_filter :setup_log_context
  after_action :store_location

  protected

    # def log4r_context
    #   ctx = Log4r::MDC.get_context.collect {|k, v| k.to_s + "=" + v.to_s }.join(" ")
    #   ctx.gsub!('%', '%%') # escape out embedded %'s so pattern formatter doesn't get confused
    #   return ctx
    # end

    def setup_log_context
      Log4r::MDC.get_context.keys.each {|k| Log4r::MDC.remove(k) }

      context = { pid: Process.pid, ip: request.remote_ip}
      context["user_id"] = current_user.id  if current_user

      content = context.map{|k,v| "#{k}=#{v}"}.join(' ')
      Log4r::MDC.put("context", content)
    end

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

      # note: cookie(change before) > user.lang(registered) > browser > default
      locale = if params[:locale]
               # Return cookie if user change locale
                  params[:locale].to_sym if I18n.available_locales.include?(params[:locale].to_sym)
                  cookies[:locale] = params[:locale]
               elsif cookies[:locale]
                  cookies[:locale] if I18n.available_locales.include?(cookies[:locale].to_sym)

               # Return db setting if registered user haven't change before
               elsif user_signed_in?
                 current_user.language if I18n.available_locales.include?(current_user.language.to_sym)

               elsif request.env['HTTP_ACCEPT_LANGUAGE']
                 check_browser_locale(request.env['HTTP_ACCEPT_LANGUAGE'])

               else
                 I18n.available_locales.first unless locale
               end

      if locale
        current_user.change_locale!(locale.to_s) if user_signed_in?
        I18n.locale = locale
      end

      # language select option
      @locale_options = { :English => 'en',
                          :Deutsch => 'de',
                          :Nederlands => 'nl',
                          :"正體中文" => "zh-TW",
                          :"ไทย" => 'th',
                          :"Türkçe" => 'tr'}
    end
    # i18n setting - end

    # Redirect back to current page after sign in
    def store_location
      return unless request.get?
      if(!request.path.match("/users") &&
         !request.path.match("/hint") &&
         !request.xhr? && # don't store ajax calls
         (request.accept && !request.accept.match(/json/))) # don't store json calls
        session[:previous_url] = request.fullpath
      end
    end

    def after_sign_in_path_for(resource)
      session[:previous_url] || authenticated_root_path
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

    # Split browser locales array and find first support language
    def check_browser_locale(browser_langs)
      accept_locales = []
      browser_langs.split(',').each do |l|
       l = l.split(';').first
       i = l.split('-')
       if 2 == i.size
         accept_locales << i[0].to_sym
         i[1].upcase!
       end
       l = i.join('-').to_sym
       accept_locales << l.to_sym
      end
      (accept_locales.select { |l| I18n.available_locales.include?(l) }).first
    end
end
