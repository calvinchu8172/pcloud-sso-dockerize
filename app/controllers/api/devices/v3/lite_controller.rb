class Api::Devices::V3::LiteController < Api::Base


  def create
    payload = api_permit
    payload[:model_class_name] = payload.delete(:model_name)
    @device = Api::Device::V3::Lite.trigger(payload.merge(ip_address: request.remote_ip))

    @device.valid?
    return render json: {:error => @device.errors[:signature].first[:description]}, :status => 400 unless @device.errors[:signature].blank?
    return render json: @device.errors[:parameter].first, :status => 400 unless @device.errors[:parameter].blank?

    render json: { result: 'success' }
  end

  private
    def api_permit
      params.permit(:mac_address, :serial_number, :model_name, :firmware_version, :signature, :module, :algo, :reset , :certificate_serial , :lan_ip)
    end
end
