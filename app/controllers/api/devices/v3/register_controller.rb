class Api::Devices::V3::RegisterController < Api::Base
  def create

    # @device = Device.checkin api_permit
    @device = Device.new
    ddns_checkin
    render :json => { result: 'test'}
  end

  private
    def api_permit
      params.permit(:mac_address, :serial_number, :model_class_name, :firmware_version, :signature, :module, :algo);
    end
end
