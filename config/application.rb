require File.expand_path('../boot', __FILE__)

require 'rails/all'

require_relative '../lib/service_logger'

#log4r requirements
require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'

require_relative '../lib/log4r/outputter/fluent_post_outputter'
require "action_mailer/railtie"
include Log4r

require 'csv'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
# APP_CONFIG = YAML.load_file('config/oauth_env_variable.yml')[Rails.env] rescue {}
# APP_CONFIG = Settings.oauth
module Pcloud
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :de, :nl, :"zh-TW", :th, :tr, :cs, :ru, :pl, :it, :hu, :fr, :es]
    # config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths << Rails.root.join('lib')

    # for bower install path
    config.assets.paths << Rails.root.join('vendor', 'assets', 'components')

    config.encoding = "utf-8"

    config.exceptions_app = self.routes

    # config.autoload_paths += Dir["#{config.root}/app/models/**/"]

    # override ActionView::Base.field_error_proc
    config.action_view.field_error_proc = Proc.new { |html_tag, instance|
      html_tag
    }

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

  end
end
