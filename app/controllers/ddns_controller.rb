# ddns 設定
# 設定流程的狀態如下
# * start: 初始化Session，透過queue 請求bot 設定DDNS
# * waiting: 等待Bot 對 ddns server 設定的過程
# * success: ddns 設定成功
# * failure: ddns 設定失敗
class DdnsController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_user!
  before_action :device_available, :only => [:show, :check]
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
    set_device_not_found_error and return if @ddns.nil?

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

  # POST /ddns/check
  # Check full domain name
  def check
    hostname = params[:host_name].downcase
    @full_domain = hostname + "." + Settings.environments.ddns
    if hostname_occupied? (hostname)
        flash[:error] = "#{@full_domain.chomp('.')} #{I18n.t('warnings.settings.ddns.exist')}"
        redirect_to action: 'show', id: params[:id]
        return
    end
    save_ddns_setting(@device, hostname)
  end

  private

    # If full domain was not exists, it will insert data to database and redirct to success page
    def save_ddns_setting(device, hostname)
      session = {device_id: device.id, host_name: hostname, domain_name: Settings.environments.ddns, status: 'start'}
      ddns_session = DdnsSession.create
      job = {:job => 'ddns', :session_id => ddns_session.id}
      if ddns_session.session.bulk_set(session) && AwsService.send_message_to_queue(job)
        redirect_to action: 'success', id: ddns_session.escaped_encrypted_id
        return
      end

      flash[:error] = I18n.t("warnings.invalid")
      redirect_to action: 'show', id: device.encoded_id
    end

    # Redirct to my device page when device is not paired for current user
    def device_available
      @device = Device.find_by_encoded_id(params[:id])
      set_device_not_found_error and return unless @device.present?
      set_device_not_found_error and return unless @device.paired_with?(current_user.id)
      set_device_not_found_error and return unless @device.has_module?(Ddns::MODULE_NAME)
    end

    # The following conditions can represents the hostname is occupied by other user:
    # * the hostname exists, and the device of ddns is not paired with current user
    # * the hostname exists, and the device of ddns is not the device that user selected to do ddns setting
    def hostname_occupied? hostname
      ddns = Ddns.find_by_hostname(hostname)
      if ddns.present?
        return true if (!ddns.device.paired_with?(current_user.id) || !ddns.setting_for_device?(@device.id))
      end
      return false
    end

    def set_device_not_found_error
      flash[:alert] = I18n.t("warnings.settings.ddns.not_found")
      redirect_to "/personal/index"
    end

    # Validation for hostname
    def validate_host_name
      filter_list = Settings.environments.filter_list

      error_conditions = {
        I18n.t("warnings.settings.ddns.too_short") => (params[:host_name].length < 3),
        I18n.t("warnings.settings.ddns.too_long") => (params[:host_name].length > 63),
        I18n.t("warnings.invalid") => (
          (/^[a-zA-Z][a-zA-Z0-9\-]*$/.match(params[:host_name]).nil?) ||
          (filter_list.include?(params[:host_name].downcase))
        )
      }

      error_conditions.map { | error_message, condition_failed |
        if condition_failed
          service_logger.note({ 'invalid_ddns' => { :error_message => error_message } })
          flash[:error] = error_message
          redirect_to action: 'show', id: params[:id]
          return
        end
      }
    end

end
