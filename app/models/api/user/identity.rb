class Api::User::Identity < Identity
  attr_accessor :certificate_serial, :signature, :user_id, :access_token
  validates_with SslValidator, signature_key: [:certificate_serial, :user_id, :access_token]
end