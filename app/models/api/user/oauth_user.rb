class Api::User::OauthUser < Api::User
  attr_accessor :certificate_serial, :signature, :user_id, :access_token, :app_key, :os, :uuid
  validates_with SslValidator, signature_key: [:certificate_serial, :user_id, :access_token, :uuid]
end