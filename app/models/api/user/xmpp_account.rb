class Api::User::XmppAccount < Api::User
	attr_accessor :certificate_serial, :signature, :cloud_id
  validates_with SslValidator, signature_key: [:cloud_id, :authentication_token, :certificate_serial]
end
