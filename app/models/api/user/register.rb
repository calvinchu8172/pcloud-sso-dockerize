class Api::User::Register < User
  attr_accessor :certificate, :signature
  validates_with CertificateValidator, signature_key: [:email, :password, :certificate]
  validates_presence_of :email, :password, :certificate, :signature, message: "invalid parameters"

end