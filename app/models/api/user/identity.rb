class Api::User::Identity < Identity
  attr_accessor :certificate, :signature
  validates_with SslValidator, signature_key: [:certificate]
end