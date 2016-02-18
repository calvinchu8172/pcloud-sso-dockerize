class Api::DevicesController < Api::Base
  before_filter :device_checking

  def create

    @device.device_session_checkin
    @device.ddns_checkin
    @device.install_module
    @device.reset_pairing
    @device.xmpp_checkin
  end

  private
    def api_permit
      params.permit(:mac_address, :serial_number, :model_name, :firmware_version, :signature, :algo, :reset, :online_status)
    end

    def device_checking
      payload = api_permit
      payload[:model_class_name] = payload.delete(:model_name)
      @device = Api::Device::V1.new(payload.merge(current_ip_address: request.remote_ip))
      @device.valid?

      error_log(payload) unless @device.errors[:magic_number].blank?
      return render json: @device.errors[:magic_number].first, :status => 400 unless @device.errors[:magic_number].blank?
      return render json: @device.errors[:parameter].first, :status => 400 unless @device.errors[:parameter].blank?

      @device.checkin
    end

    def error_log payload
        payload.delete_if{ |key, value| ['mac_address', 'serial_number', 'signature'].include?(key) }
        logger.error("There is an 'Invalid signature error' when device registering , payload_data: #{payload.to_json}}")
    end
end
