Devise::Async.setup do |config|
  config.enabled = true
  config.backend = :sidekiq
end

REDIS_HOST =  "redis://" + Settings.redis.host + ":" + Settings.redis.port.to_s

Sidekiq.configure_server do |config|
  config.redis = { url: REDIS_HOST }
end
Sidekiq.configure_client do |config|
  config.redis = { url: REDIS_HOST }
end