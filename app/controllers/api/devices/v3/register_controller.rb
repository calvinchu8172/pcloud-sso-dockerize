class Api::Devices::V3::RegisterController < Api::DeviceController
  before_filter :device_checking

  private
    def api_permit
      params.permit(:mac_address, :serial_number, :model_class_name, :firmware_version, :signature, :module, :algo, :reset)
    end

    def device_checking
      payload = api_permit
      payload[:model_class_name] = payload.delete(:model_name)
      @device = Api::Device::V3.checkin(api_permit.merge(current_ip_address: request.remote_ip))
      return render :json => {:result => 'invalid parameter'}, :status => 400 if @device.nil?
      @device.valid?
      return render json: @device.errors.values[0].first, :status => 400  unless @device.errors.blank?
    end
end
