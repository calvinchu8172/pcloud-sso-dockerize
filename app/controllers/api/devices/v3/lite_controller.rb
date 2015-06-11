class Api::Devices::V3::LiteController < Api::DeviceController
  

  def create
    payload = api_permit
    payload[:model_class_name] = payload.delete(:model_name)
    @device = Api::Device::V3::Lite.trigger(api_permit.merge(ip_address: request.remote_ip))
    
    return render json: @device.errors.values[0].first unless @device.valid?

    render json: {result: 'success'}
  end

  private
    def api_permit
      params.permit(:mac_address, :serial_number, :model_class_name, :firmware_version, :signature, :module, :algo, :reset)
    end
end