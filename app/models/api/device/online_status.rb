class Api::Device::OnlineStatus < Api::Device
  attr_accessor :device_data, :certificate_serial
  validate :device_checking # , message: "Invalid device."
  validates_presence_of :online_status, message: "Invalid status."
  validates_presence_of :certificate_serial, message: "Invalid certificate_serial."
  validates_presence_of :signature, message: "Invalid signature, not present."
  validates_with SslValidator, signature_key: [:certificate_serial, :mac_address, :serial_number, :online_status, :wol_status]

  def device_checking
    @device_data = Device.find_by(serial_number: self.serial_number, mac_address: self.mac_address)
    if @device_data.blank?
      errors.add(:device, "Invalid device.")
    else
      @device_data
    end
  end
end