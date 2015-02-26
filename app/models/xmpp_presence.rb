class XmppPresence < Redis::Set

  def initialize(key)
  	super(key, @@xmpp_redis)
  end

  def self.xmpp_redis= conn
  	@@xmpp_redis = conn
  end

  def self.xmpp_redis
  	@@xmpp_redis
  end
end