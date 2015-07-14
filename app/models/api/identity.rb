class Api::Identity < Identity
  attr_accessor :certificate_serial, :signature, :user_id, :access_token, :uuid
  validates_with SslValidator, signature_key: [:certificate_serial, :user_id, :access_token, :uuid]
end