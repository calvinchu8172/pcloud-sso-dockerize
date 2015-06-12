class Api::User::Identity < Identity
  attr_accessor :certificate_serial, :signature
  validates_with SslValidator, signature_key: [:certificate_serial]
end