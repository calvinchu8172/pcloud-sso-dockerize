class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  include Locale
  before_filter :set_locale

  before_filter :setup_log_context
  after_action :store_location

  protected

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

    # Redirect back to current page after sign in
    def store_location
      return unless request.get?
      if(!request.path.match("/users") &&
         !request.path.match("/hint") &&
         !request.path.match("/oauth") &&
         !request.xhr? && # don't store ajax calls
         (request.accept && !request.accept.match(/json/))) # don't store json calls
        session[:previous_url] = request.fullpath
      end
    end

    def after_sign_in_path_for(resource)
      session[:previous_url] || authenticated_root_path
    end

    def device_paired_with?
      @device = Device.find_by_encrypted_id(URI.decode(params[:id]))
      unless(@device.pairing.owner.first.user_id == current_user.id)
        flash[:alert] = I18n.t('warnings.invalid_device')
        redirect_to :authenticated_root
      end
    end

    def push_to_queue_cancel(title, tag)
      data = {job: "cancel", title: title, tag: tag}

      sqs = AWS::SQS.new
      queue = sqs.queues.named(Settings.environments.sqs.name)
      queue.send_message(data.to_json)
    end

    # Split browser locales array and find first support language
    def get_browser_locale(browser_langs)
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
