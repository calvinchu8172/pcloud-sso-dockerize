Redis.current = Redis.new(:host => Settings.redis.web_host, :port => Settings.redis.port)
XmppPresence.xmpp_redis = Redis.new(:host => Settings.redis.xmpp_host, :port => Settings.redis.port)