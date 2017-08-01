require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

require_relative '../lib/service_logger'

#log4r requirements
require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'
require_relative '../lib/log4r/outputter/fluent_post_outputter'
include Log4r

require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Pcloud
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths << Rails.root.join('lib')

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :de, :nl, :"zh-TW", :th, :tr, :cs, :ru, :pl, :it, :hu, :fr, :es]
    config.i18n.fallbacks = true

    config.exceptions_app = self.routes

    # override ActionView::Base.field_error_proc
    # config.action_view.field_error_proc = Proc.new { |html_tag, instance|
    #   html_tag
    # }

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # assign log4r's logger as rails' logger.
    unless Rails.env.development?
      log4r_config= YAML.load_file(File.join(File.dirname(__FILE__),"log4r.yml"))
      YamlConfigurator.decode_yaml( log4r_config[Rails.env]['log4r_config'] )
      config.logger = Log4r::Logger["application"]
      ActiveRecord::Base.logger = Log4r::Logger["database"]
      # ActiveRecord::Base.logger = Log4r::Logger[Rails.env]
    end

    # application with api
    config.api_only = false

    cache_store_settings = {
      host: Settings.redis.web_host,
      port: Settings.redis.port,
      db: Settings.redis.session_cache_db,
      namespace: "cache"
    }

    unless Settings.redis.cache_expires_after.blank?
      cache_store_settings[:expire_after] = Settings.redis.cache_expires_after.to_i.days
    end

    config.cache_store = :redis_store, cache_store_settings

  end
end
