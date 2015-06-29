class Api::Device::V3 < Api::Device
  validates_with SslValidator, signature_key: [:certificate_serial, :mac_address, :serial_number, :model_class_name, :firmware_version]
  attr_accessor :certificate_serial
end