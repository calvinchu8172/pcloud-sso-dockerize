class Api::DeviceController < Api::Base

  def create

    @device.ddns_checkin
    @device.install_module
    @device.device_session_checkin
    @device.reset_pairing

    @device.xmpp_checkin
  end

  private
    def api_permit
      params.permit(:mac_address, :serial_number, :model_class_name, :firmware_version, :signature, :algo, :reset)
    end

    def device_checking
      @device = Api::Device.checkin(api_permit.merge(current_ip_address: request.remote_ip))
      return render :json => {:result => 'invalid parameter'}, :status => 400 if @device.nil?
    end
end
