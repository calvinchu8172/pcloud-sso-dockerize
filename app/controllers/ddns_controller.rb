class DdnsController < ApplicationController
  before_action :authenticate_user!
  before_action :device_available, :only => [:setting]
  before_action :validate_host_name, :only => [:check]

  def setting
    @hostname = ""
    if @device.ddns
      @hostname = @device.ddns.hostname
    end
    @domain_name = Settings.environments.ddns
  end

  def success

    @ddns = DdnsSession.find_by_encrypted_id(params[:id])
    return error_action if @ddns.empty

    raw_ddns_session = @ddns.session.all
    raw_ddns_session['id'] = @ddns.id
    
    @device = Device.find raw_ddns_session['device_id']
    # If this device is first paired, the confirm link should goto upnp setting page
    if session[:first_pairing]
      @link_path = upnp_path(@device.escaped_encrypted_id)
      session[:first_pairing] = false
    else
      @link_path = "/personal/index"
    end

    @full_domain = raw_ddns_session['host_name'] + "." + Settings.environments.ddns
    @ddns_session[:encrypted_id] = @ddns.escaped_encrypted_id
    @ddns_session[:encrypted_device_id] = @device.escaped_encrypted_id
    @ddns_session[:status] = raw_ddns_session['status']
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @ddns_session }
    end
  end

  # Set error message and redirect to setting page
  def failure
    flash[:error] = I18n.t("warnings.settings.ddns.failure")
    redirect_to action: 'setting', id: params[:id]
  end

  # Check full domain name
  def check

    hostname = params[:host_name].downcase
    @full_domain = hostname + "." + Settings.environments.ddns
    # Need compare domain id when domain name have multiple
    ddns = Ddns.find_by_hostname(hostname)
    filter_list = Settings.environments.filter_list
    # If hostname was exits, it will redirct to setting page and display error message
    if ddns && !paired?(ddns.device_id)
      flash[:error] = @full_domain + " " + I18n.t("warnings.settings.ddns.exist")
      redirect_to action: 'setting', id: params[:id]
      return
    elsif filter_list.include?(hostname)
      flash[:error] = @full_domain + " " + I18n.t("warnings.settings.ddns.exist")
      redirect_to action: 'setting', id: params[:id]
      return
    end

    device = Device.find_by_encrypted_id(URI.decode(params[:id]))
    save_ddns_setting(device, hostname)
  end

  # Send ajax
  def status
    ddns = DdnsSession.find(params[:id])
    result = ddns.session.all
    result[:id] = ddns.id
    render :json => result
  end

  private

    # If full domain was not exits, it will insert data to database and redirct to success page
    def save_ddns_setting(device, hostname)
      # job = Job::DdnsMessage.new
      session = {device_id: device.id, host_name: hostname, domain_name: Settings.environments.ddns, status: 'start'}
      ddns_session = DdnsSession.create
      job = {:job => 'ddns', :session_id => ddns_session.id}
      if ddns_session.session.bulk_set(session) && AWS::SQS.new.queues.named(Settings.environments.sqs.name).send_message(job.to_json)
        redirect_to action: 'success', id: ddns_session.escaped_encrypted_id
        return
      end

      flash[:error] = I18n.t("warnings.invalid")
      redirect_to action: 'setting', id: device.escaped_encrypted_id
    end

    # Redirct to my device page when device is not paired for current user
    def device_available
      @device = Device.find_by_encrypted_id(params[:id])
      if @device
        if !paired?(@device.id)
          error_action
        end
      else
        error_action
      end
    end

    def paired?(device_id)
      Pairing.owner.exists?(['device_id = ? and user_id = ?', device_id, current_user.id])
    end

    def error_action
      flash[:error] = I18n.t("warnings.settings.ddns.not_found")
      redirect_to "/personal/index"
    end
    # Redirct to my device page when device is not paired for current user - end

    # Validation for hostname
    def validate_host_name
      valid = false

      if params[:host_name].length < 3
        valid = true
        error_message = I18n.t("warnings.settings.ddns.too_short")
      elsif params[:host_name].length > 63
        valid = true
        error_message = I18n.t("warnings.settings.ddns.too_long")
      elsif /^[a-zA-Z][a-zA-Z0-9\-]*$/.match(params[:host_name]).nil?
        valid = true
        error_message = I18n.t("warnings.invalid")
      end

      if valid
        flash[:error] = error_message
        redirect_to action: 'setting', id: params[:id]
      end
    end
end
