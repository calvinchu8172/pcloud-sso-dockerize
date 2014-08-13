class DdnsController < ApplicationController
  before_action :authenticate_user!
  before_action :device_available, :only => [:setting]
  before_action :validate_host_name, :only => [:check]

  def setting
    @ddns_session = DdnsSession.new
    @device = Device.find(params[:id])
    @hostname = ""
    if @device.ddns
      @hostname = @device.ddns.full_domain.split(".").first
    end
    @domain_name = Settings.environments.ddns
  end

  def success
    @ddns_session = DdnsSession.find(params[:id])

    # If this device is first paired, the confirm link should goto upnp setting page
    if session[:first_pairing]
      @link_path = upnp_path(@ddns_session.device_id)
      session[:first_pairing] = false
    else
      @link_path = "/personal/index"
    end
  end

  # Set error message and redirect to setting page
  def failure
    flash[:error] = I18n.t("warnings.settings.ddns.failure")
    redirect_to action: 'setting', id: params[:id]
  end

  # Check full domain name
  def check
    @ddns_params = params[:ddns_session]
    hostname = params[:hostName].downcase
    @full_domain = hostname + "." + Settings.environments.ddns
    ddns = Ddns.find_by_full_domain(@full_domain)
    filter_list = Settings.environments.filter_list

    # If full domain was exits, it will redirct to setting page and display error message
    if ddns && !paired?(ddns.device_id)
      flash[:error] = @full_domain + " " + I18n.t("warnings.settings.ddns.exist")
      redirect_to action: 'setting', id: @ddns_params[:device_id]
      return
    elsif filter_list.include?(hostname)
      flash[:error] = @full_domain + " " + I18n.t("warnings.settings.ddns.exist")
      redirect_to action: 'setting', id: @ddns_params[:device_id]
      return
    end

    save_ddns_setting
  end

  # Send ajax
  def status
    @session = DdnsSession.find(params[:id])
    render :json => @session.to_json(:only => [:id, :device_id, :full_domain, :status])
  end

  private

    # If full domain was not exits, it will insert data to database and redirct to success page
    def save_ddns_setting
      job = Job::DdnsMessage.new

      if job.push({device_id: @ddns_params[:device_id], full_domain: @full_domain})
        redirect_to action: 'success', id: job.session.id
        return
      end

      flash[:error] = I18n.t("warnings.invalid")
      redirect_to action: 'setting', id: @ddns_params[:device_id]
    end

    # Redirct to my device page when device is not paired for current user
    def device_available
      device = Device.find_by_id(params[:id])
      if device
        if !paired?(device.id)
          error_action
        end
      else
        error_action
      end
    end

    def paired?(device_id)
      Pairing.exists?(['device_id = ? and user_id = ? and enabled = 1', device_id, current_user.id])
    end

    def error_action
      flash[:error] = I18n.t("warnings.settings.ddns.not_found")
      redirect_to "/personal/index"
    end
    # Redirct to my device page when device is not paired for current user - end

    def validate_host_name
      valid = false

      if params[:hostName].length < 3 
        valid = true
        error_message = I18n.t("warnings.settings.ddns.too_short")
      elsif params[:hostName].length > 63
        valid = true
        error_message = I18n.t("warnings.settings.ddns.too_long")
      elsif /^[a-zA-Z][a-zA-Z0-9\-]*$/.match(params[:hostName]).nil?
        valid = true
        error_message = I18n.t("warnings.invalid")
      end

      if valid
        flash[:error] = error_message
        redirect_to action: 'setting', id: params[:ddns_session][:device_id]
      end
    end
end
