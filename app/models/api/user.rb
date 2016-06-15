class Api::User < User
  include Guards::AttrEncryptor
  include Redis::Objects

  attr_accessor :account_token, :authentication_token

  hash_key :app_info

  AUTHENTICATION_TOKEN_TTL = 6.hour
  ACCOUNT_TOKEN_TTL = 1.month
  INVALID_SIGNATURE_ERROR = {error_code: "101", description: "Invalid signature"}
  INVALID_TOKEN_AUTHENTICATION = {error_code: '201', description: 'Invalid cloud id or token.'}

  def authentication_token_key(user_id, token)
    "user:#{user_id}:authentication_token:#{token}"
  end

  # Create user's authentication token
  def create_authentication_token
    @authentication_token = SecureRandom.urlsafe_base64(nil, false)
    redis_token = Redis::Value.new(authentication_token_key(id.to_s, @authentication_token))
    expire_time = DateTime.now + AUTHENTICATION_TOKEN_TTL
    redis_token.value = expire_time.to_s
    redis_token.expireat(expire_time.to_i)
    @authentication_token
  end

  def account_token_key(token)
    "user:#{id}:account_token:#{token}"
  end

  #including account token and authentication token
  def create_token_set
    @account_token = SecureRandom.urlsafe_base64(nil, false)
    @authentication_token = create_authentication_token
    key = account_token_key(@account_token)
    redis_token = Redis::HashKey.new(key)
    expire_time = DateTime.now + ACCOUNT_TOKEN_TTL
    redis_token.bulk_set({expire_at: expire_time.to_s, authentication_token: @authentication_token})
    redis_token.expireat(expire_time.to_i)
    {account_token: @account_token, authentication_token: @authentication_token}
  end

  def authentication_token_ttl
    AUTHENTICATION_TOKEN_TTL.seconds
  end

  def registered_in_portal_oauth?
    self.password.blank? && self.identity.length > 0
  end

  def apply_for_xmpp_account

    info = {id: "m#{generate_xmpp_account}", password: generate_new_passoword}
    xmpp_user = XmppUser.find_or_initialize_by(username: info[:id])
    xmpp_user.password = info[:password]


    # ------------------- #
    # ------ debug ------ #
    # ------------------- #
    logger.info("find or initialize user: #{xmpp_user.to_json} ")
    logger.info("id: #{info[:id]}")
    existing_xmpp_user = XmppUser.find_by(username: info[:id])
    logger.info("existing_xmpp_user: #{existing_xmpp_user.to_json}")

    xmpp_user.save
    info[:id] += "@#{Settings.xmpp.server}"
    info
  end

  def confirmed_in_grace_period?
    !(((Time.zone.now - created_at) / 1.day) > 3 and !confirmed?)
  end

  def verify_authentication_token(token)
    redis_token = Redis::Value.new(authentication_token_key(id.to_s, token))
    return false if redis_token.nil?

    if DateTime.strptime(redis_token.value) > DateTime.now
      expire_time = DateTime.now + AUTHENTICATION_TOKEN_TTL
      redis_token.value = expire_time.to_s
      redis_token.expireat(expire_time.to_i)
      return true
    else
      return false
    end
  end

  protected
    def generate_xmpp_account
      url_safe_encode64(email + '-' + uuid.to_s )
    end

    #用英數產生密碼，大小寫有別
    def generate_new_passoword
      origin = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
      (0...10).map { origin[rand(origin.length)] }.join
   end
end