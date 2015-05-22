class Api::User::Token < Api::User
  
  def self.authenticate(payload = {})

    user = self.find_for_database_authentication(email: payload[:email])
    return unless user
    return unless user.valid_password?(payload[:password])

    user
  end

  def revoke_authentication_token key
    redis_token = Redis::Value.new(authentication_token_key(id.to_s, key))
    redis_token.delete
  end

end