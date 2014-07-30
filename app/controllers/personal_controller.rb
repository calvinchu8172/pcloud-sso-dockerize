class PersonalController < ApplicationController
  before_action :authenticate_user!

  def index
    @pairing = Pairing.enabled.where(user_id: current_user.id, enabled: 1)
    if !@pairing.empty?
      @paired = true
    else
      @paired = false
      flash[:alert] = I18n.t("warnings.no_pairing_device") if current_user.sign_in_count == 0
      redirect_to "/discoverer/index"
    end
  end

  def profile
    @language = @locale_options.has_value?(current_user.language) ? @locale_options.key(current_user.language) : "English"
  end

  protected
    def get_info(pairing)
      info_hash = Hash.new
      info_hash[:model_name] = pairing.device.model_name
      if pairing.device.ddns
        info_hash[:class_name] = "orange"
        info_hash[:title] = pairing.device.ddns.full_domain
        info_hash[:ip] = pairing.device.ddns.ip_address
        info_hash[:date] = pairing.device.ddns.updated_at.strftime("%Y/%m/%d")
      else
        info_hash[:class_name] = "gray"
        info_hash[:title] = I18n.t("warnings.not_config")
        info_hash[:ip] = pairing.device.device_session.ip
      end
      info_hash
    end
    helper_method :get_info
end
