Redis.current = Redis.new(:host => Settings.redis.web_host, :port => Settings.redis.port)
# Redis.current = Redis.new(:host => 'pcloud-beta-web.hcv1lh.0001.use1.cache.amazonaws.com', :port => Settings.redis.port)
XmppPresence.xmpp_redis = Redis.new(:host => Settings.redis.xmpp_host, :port => Settings.redis.port)
# XmppPresence.xmpp_redis = Redis.new(:host => 'pcloud-beta-xmpp.hcv1lh.0001.use1.cache.amazonaws.com', :port => Settings.redis.port)
