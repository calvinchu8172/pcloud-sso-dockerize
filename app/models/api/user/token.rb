class Api::User::Token < Api::User
  attr_accessor :certificate_serial, :signature, :app_key, :os, :uuid
  validates_with SslValidator, signature_key: [:email, :certificate_serial, :uuid]

  def self.authenticate(payload = {})
    payload[:email] = payload.delete(:id)
    user = self.find_for_database_authentication(email: payload[:email])
    unless user and user.valid_password?(payload[:password])
      user = self.new(email: payload[:email])
      user.errors.add(:authenticate, {error_code: '001', description: 'Invalid email or password.'})
      return user
    end

    user.signature = payload[:signature]
    user.certificate_serial = payload[:certificate_serial]
    user.app_key = payload[:app_key]
    user.os = payload[:os]
    user.uuid = payload[:uuid]
    user.valid?
    unless user.errors["signature"].blank?
      user.errors.add(:authenticate, Api::User::INVALID_SIGNATURE_ERROR)
      return user
    end

    user.create_token

    if ((Time.zone.now - user.created_at) / 1.day) > 3 and !user.confirmed?
      user.errors.add(:authenticate, {error_code: '002',
                                      description: 'client have to confirm email account before continuing.',
                                      user_id: user.encoded_id,
                                      account_token: user.account_token,
                                      authentication_token: user.authentication_token,
                                      timeout: user.authentication_token_ttl
                                      })
      return user
    end
    user
  end

  def renew_authentication_token(account_token)
    redis_token = get_account_token(account_token)
    return false if redis_token.blank? or expired?(redis_token.get(:expire_at))

    revoke_authentication_token(redis_token.get(:authentication_token))
    authentication_token = create_authentication_token
    expire_time = DateTime.now + ACCOUNT_TOKEN_TTL
    redis_token.bulk_set({expire_at: expire_time.to_s, authentication_token: authentication_token})
    redis_token.expireat(expire_time.to_i)
    authentication_token
  end

  # Create user's account token and authentication token
  # @return [Hash] The token string of account_token and authentication_token
  def create_token
    @account_token = SecureRandom.urlsafe_base64(nil, false)
    @authentication_token = create_authentication_token
    key = account_token_key(@account_token)
    redis_token = Redis::HashKey.new(key)
    expire_time = DateTime.now + ACCOUNT_TOKEN_TTL
    redis_token.bulk_set({expire_at: expire_time.to_s, authentication_token: @authentication_token})
    redis_token.expireat(expire_time.to_i)
    update_app_info
    {account_token: @account_token, authentication_token: @authentication_token}
  end

  # Revoke account_token by account token string.
  # @note This method will also delete the authentication token related to the deleted account token
  # @param [String] account_token The account token string
  # @return [Boolean] whether the account token is deleted
  def revoke_token(account_token)
    redis_token = get_account_token(account_token)
    return false if redis_token.empty?
    revoke_app_info(account_token)

    revoke_authentication_token(redis_token.get(:authentication_token))
    redis_token.clear
  end

  # Revoke authentication_token by authentication token string.
  # @param [String] key The authentication token string
  # @return
  def revoke_authentication_token key
    redis_token = Redis::Value.new(authentication_token_key(id.to_s, key))
    redis_token.delete unless redis_token.nil?
  end

  # Revoke all account_tokens and authentication_tokens of the user.
  def revoke_all_account_and_authentication_tokens
    self.redis.keys(account_token_key('*')).each do |token_key|
      token = token_key.gsub("user:#{id}:account_token:", '')
      revoke_token(token)
    end
  end

  private
    def get_account_token(account_token)
      Redis::HashKey.new(account_token_key(account_token))
    end

    def expired?(expire_at)
      DateTime.strptime(expire_at) < DateTime.now
    end
    def update_app_info
      return false if app_key.blank? or os.blank? or !['0', '1', '2'].include?(os)
      app_info.bulk_set(app_key: app_key, os: os, account_token: account_token)
    end

    def revoke_app_info(account_token)
      return unless app_info[:account_token] == account_token
      app_info.clear
    end
end