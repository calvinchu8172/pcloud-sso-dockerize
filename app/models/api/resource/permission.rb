class Api::Resource::Permission < AcceptedUser
	attr_accessor :certificate_serial, :signature, :device_account, :cloud_id
	validates_presence_of :certificate_serial, message: "invalid certificate serial."
	validates_presence_of :signature, message: "invalid signature."
	validates_presence_of :device_account, message: "invalid device account."
	validates_presence_of :cloud_id, message: "invalid cloud id."
	validates_with SslValidator, signature_key: [:certificate_serial, :device_account, :cloud_id]
end