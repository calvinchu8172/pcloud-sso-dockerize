class Api::Device::V3::RegisterController < Api::Device
  def create

    @device = Device.checkin api_permit
    ddns_checkin
    install_module
    device_session_checkin
    reset

    xmpp_checkin

    render :json => {:xmpp_account => @account[:name] + '@' + Settings.xmpp.server + "/" + Settings.xmpp.device_resource_id,
                     :xmpp_password => @account[:password],
                     :xmpp_bots => Settings.xmpp.bots,
                     :xmpp_ip_addresses => Settings.xmpp.nodes}
  	render json: {result: 'v3'}
  end

  private
    def api_permit
      params.permit(:mac_address, :serial_number, :model_class_name, :firmware_version, :signature, :module, :algo);
    end
end
