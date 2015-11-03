class PairingLog < ActiveRecord::Base

  enum status: { pair: 1, unpair: 2,  device_reset: 3 }

  def self.record_pairing_log(device_id, user_id, ip_address, status)
    pairing_log = self.new
    pairing_log.user_id = user_id
    pairing_log.device_id = device_id
    pairing_log.ip_address = ip_address
    pairing_log.status = status
    pairing_log.save
  end

end
