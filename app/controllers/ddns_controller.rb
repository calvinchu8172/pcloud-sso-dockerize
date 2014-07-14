class DdnsController < ApplicationController
  before_action :authenticate_user!
  before_action :device_available, :only => [:setting]
  before_action :validate_host_name, :only => [:check]

  def setting
    @ddns_session = DdnsSession.new
    @device = Device.find(params[:id])
    @domain_name = Settings.environments.ddns
  end

  def success
    @ddns_session = DdnsSession.find(params[:id])
  end

  # Set error message and redirect to setting page
  def failure
    flash[:error] = "更新失敗，請稍後再試!"
    redirect_to action: 'setting', id: params[:id]
  end

  # Check full domain name
  def check
    @ddns_params = params[:ddns_session]
    @full_domain = params[:hostName] + "." + Settings.environments.ddns
    ddns = Ddns.exists?(:full_domain => @full_domain)

    # If full domain was exits, it will redirct to setting page and display error message
    if ddns
      flash[:error] = @full_domain + "已存在"
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

      flash[:error] = params[:hostName] + " is invalid"
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
      flash[:error] = "您沒有與該device配對，或是該device不存在！"
      redirect_to "/personal/index"
    end
    # Redirct to my device page when device is not paired for current user - end

    def validate_host_name
      logger.debug("host name:" + params[:hostName]);
      if /^[a-zA-Z][a-zA-Z0-9\-]*$/.match(params[:hostName]).nil?
        flash[:error] = params[:hostName] + " is invalid"
        logger.debug("host name:" + params[:hostName] + " is invalid");
        redirect_to action: 'setting', id: params[:ddns_session][:device_id]
      end
    end
end
