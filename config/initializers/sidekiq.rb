redis_url = "redis://#{Settings.redis.web_host}:#{Settings.redis.port}"
Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
  end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
