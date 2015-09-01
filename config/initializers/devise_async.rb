# Supported options: :resque, :sidekiq, :delayed_job, :queue_classic, :torquebox, :backburner, :que, :sucker_punch
Devise::Async.backend = :sidekiq
Devise::Async.setup do |config|
  config.enabled = Rails.env == 'test' ? false : true
  config.backend = :sidekiq
  config.queue = :mailer
end

