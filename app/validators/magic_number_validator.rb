class MagicNumberValidator < ActiveModel::Validator

  def validate(record)

    magic_number = Settings.magic_number
    mac_address = record.mac_address || ''
    serial_number = record.serial_number || ''
    model_class_name = record.model_class_name || ''
    firmware_version = record.firmware_version || ''
    signature = record.signature || ''

    data = mac_address + serial_number.to_s + model_class_name + firmware_version + magic_number.to_s
    sha224 = OpenSSL::Digest::SHA224.new
    signature_inside = sha224.hexdigest(data)

    unless signature == signature_inside
      record.errors[:magic_number] = {:error => "Failure"}
    end
  end
    
end