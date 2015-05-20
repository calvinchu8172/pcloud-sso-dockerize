class Api::User::Register < Api::User
  attr_accessor :certificate_serial, :signature
  validates_with SslValidator, signature_key: [:email, :password, :certificate_serial]
  validates_presence_of :email, :password, :certificate_serial, :signature, message: "invalid parameters"

end