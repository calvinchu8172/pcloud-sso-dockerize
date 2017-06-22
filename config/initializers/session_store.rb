# Be sure to restart your server when you modify this file.

# Rails.application.config.session_store :cookie_store, key: '_pcloud_session'

session_store_settings = {
  servers: [
    {
      host: Settings.redis.web_host,
      port: Settings.redis.port,
      db: Settings.redis.session_cache_db,
      namespace: "session"
    }
  ]
}

unless Settings.redis.session_expires_after.blank? 
  session_store_settings[:expire_after] = Settings.redis.session_expires_after.to_i.days
end

Rails.application.config.session_store :redis_store, session_store_settings