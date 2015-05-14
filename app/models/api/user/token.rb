class Api::User::Token < Api::User
  attr_accessor :account_token, :authentication_token

  AUTHENTICATION_TOKEN_TTL = 1.hour
  ACCOUNT_TOKEN_TTL = 1.month

  def self.authenticate(payload = {})

    user = self.find_for_database_authentication(email: payload[:email])
    return unless user
    return unless user.valid_password?(payload[:password])

    user
  end

  def authentication_token_key
    "user:#{id}:account_token"
  end

  def create_authentication_token
    @authentication_token = SecureRandom.urlsafe_base64(nil, false)
    key = authentication_token_key + ':' + @authentication_token
    redis_token = Redis::Value.new(key)
    redis_token.value = (DateTime.now + AUTHENTICATION_TOKEN_TTL).to_s
    @authentication_token
  end

  def account_token_key
    "user:#{id}:account_token"
  end

  #including account token and authentication token
  def create_token_set
    @account_token = SecureRandom.urlsafe_base64(nil, false)
    @authentication_token = create_authentication_token
    key = account_token_key + ':' + @account_token
    redis_token = Redis::HashKey.new(key)
    redis_token.bulk_set({expire_at: (DateTime.now + ACCOUNT_TOKEN_TTL).to_s, authentication_token: @authentication_token}) 
    {account_token: @account_token, authentication_token: @authentication_token}
  end

  def authentication_token_ttl
    AUTHENTICATION_TOKEN_TTL.seconds
  end

  def apply_for_xmpp_account

    info = {id: "m#{generate_xmpp_account}@#{Settings.xmpp.server}",
            password: generate_new_passoword}
    xmpp_user = XmppUser.find_or_initialize_by(username: info[:id])
    xmpp_user.password = info[:password]
    xmpp_user.save
    info
  end

  def self.verify_authentication_token token

  end

  def self.revoke_authentication_token key
    redis_token = Redis::Value.new(authentication_token_key + ':' + key)
    redis_token.delete
  end

  private
    def generate_xmpp_account
      url_safe_encode64(email)
    end

    #用英數產生密碼，大小寫有別
    def generate_new_passoword
      origin = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
      (0...10).map { origin[rand(origin.length)] }.join
   end
end