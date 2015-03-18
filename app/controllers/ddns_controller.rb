# ddns 設定
# 設定流程的狀態如下
# * start: 初始化Session，透過queue 請求bot 設定DDNS
# * waiting: 等待Bot 對 ddns server 設定的過程
# * success: ddns 設定成功
# * failure: ddns 設定失敗
class DdnsController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_user!
  before_action :device_available, :only => [:show]
  before_action :validate_host_name, :only => [:check]

  def show
    @hostname = ""
    if @device.ddns
      @hostname = @device.ddns.hostname
    end
    @domain_name = Settings.environments.ddns

    service_logger.note({'setting_ddns' => {'hostname' => @hostname, 'domain_name' => @domain_name}})
  end

  def success

    @ddns = DdnsSession.find_by_encrypted_id(URI.decode(params[:id]))
    error_action and return if @ddns.nil?

    raw_ddns_session = @ddns.session.all
    raw_ddns_session['id'] = @ddns.id

    @device = Device.find raw_ddns_session['device_id']
    # If this device is first paired, the confirm link should goto upnp setting page
    if session[:first_pairing]
      @link_path = tutorial_path(@device, Ddns::MODULE_NAME)
      session[:first_pairing] = false
    else
      @link_path = "/personal/index"
    end

    @full_domain = raw_ddns_session['host_name'] + "." + Settings.environments.ddns.chomp('.')

    @ddns_session = { :encrypted_id => @ddns.escaped_encrypted_id,
                      :encrypted_device_id => @device.escaped_encrypted_id,
                      :status => raw_ddns_session['status']}

    service_logger.note({'success_ddns' => @ddns_session})
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @ddns_session }
    end
  end

  # Set error message and redirect to setting page
  def failure
    flash[:error] = I18n.t("warnings.settings.ddns.failure")
    redirect_to action: 'show', id: CGI::escape(params[:id])
  end

  # POST /ddns/check
  # Check full domain name
  def check

    hostname = params[:host_name].downcase
    @full_domain = hostname + "." + Settings.environments.ddns
    # Need compare domain id when domain name have multiple
    ddns = Ddns.find_by_hostname(hostname)
    filter_list = Settings.environments.filter_list
    # If hostname was exits, it will redirct to setting page and display error message
    if ddns && !paired?(ddns.device_id)
      flash[:error] = @full_domain.chomp('.') + " " + I18n.t("warnings.settings.ddns.exist")
      redirect_to action: 'show', id: params[:id]
      return
    elsif filter_list.include?(hostname)
      flash[:error] = @full_domain.chomp('.') + " " + I18n.t("warnings.settings.ddns.exist")
      redirect_to action: 'show', id: params[:id]
      return
    end

    device = Device.find_by_encrypted_id(URI.decode(params[:id]))
    save_ddns_setting(device, hostname)
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
      redirect_to action: 'show', id: device.escaped_encrypted_id
    end

    # Redirct to my device page when device is not paired for current user
    def device_available
      @device = Device.find_by_encrypted_id(params[:id])
      if @device
        if !paired?(@device.id) || !@device.find_module_list.include?(Ddns::MODULE_NAME)
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
      invalid = false

      if params[:host_name].length < 3
        invalid = true
        error_message = I18n.t("warnings.settings.ddns.too_short")
      elsif params[:host_name].length > 63
        invalid = true
        error_message = I18n.t("warnings.settings.ddns.too_long")
      elsif /^[a-zA-Z][a-zA-Z0-9\-]*$/.match(params[:host_name]).nil?
        invalid = true
        error_message = I18n.t("warnings.invalid")
      end

      if invalid
        service_logger.note({'invalid_ddns' => {:error_message => error_message}})
        flash[:error] = error_message
        redirect_to action: 'show', id: params[:id]
      end
    end
end
