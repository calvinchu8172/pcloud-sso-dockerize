class Api::Resource::Permission < AcceptedUser
	attr_accessor :certificate_serial, :signature, :device_account, :cloud_id
	validates_presence_of :certificate_serial, message: "Invalid certificate_serial."
	validates_presence_of :signature, message: "Invalid signature."
	validates_presence_of :device_account, message: "Invalid device."
	validates_presence_of :cloud_id, message: "Invalid cloud id."
	validates_with SslValidator, signature_key: [:certificate_serial, :device_account, :cloud_id]
end