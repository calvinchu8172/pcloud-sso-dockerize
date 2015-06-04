class Api::Resource::Permission < AcceptedUser
	attr_accessor :certificate, :signature, :device_account, :cloud_id
	validates_presence_of :certificate, message: "invalid cerificate."
	validates_presence_of :signature, message: "invalid signature."
	validates_presence_of :device_account, message: "invalid device account."
	validates_presence_of :cloud_id, message: "invalid cloud id."
	validates_with SslValidator, signature_key: [:certificate, :device_account, :cloud_id]
end