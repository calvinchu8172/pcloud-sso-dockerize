class Api::Devices::V3::RegisterController < Api::DeviceController
  before_filter :device_checking

  private
    def api_permit
      params.permit(:mac_address, :serial_number, :model_class_name, :firmware_version, :signature, :module, :algo, :reset)
    end

    def device_checking
      payload = api_permit
      payload[:model_class_name] = payload.delete(:model_name)
      @device = Api::Device::V3.new(payload.merge(current_ip_address: request.remote_ip))
      @device.valid?
      return render json: @device.errors[:magic_number].first, :status => 400 unless @device.errors[:magic_number].blank?
      return render json: @device.errors[:parameter].first, :status => 400 unless @device.errors[:parameter].blank?

      @device.checkin
    end
end
