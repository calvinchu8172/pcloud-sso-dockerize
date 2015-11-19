class Api::Devices::V1::RegisterController < Api::DevicesController
  def api_permit
    params.permit(:mac_address, :serial_number, :model_name, :firmware_version, :signature, :algo, :reset)
  end
end
