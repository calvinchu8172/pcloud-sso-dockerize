class Api::Devices::V2::RegisterController < Api::DevicesController

  def api_permit
    params.permit(:mac_address, :serial_number, :model_name, :firmware_version, :signature, :module, :algo, :reset)
  end
end
