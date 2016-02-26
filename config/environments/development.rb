Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  # config.action_mailer.default_url_options = { host: 'pcloud.dev'}

  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = { :address => "localhost", :port => 1025, :from => "do-not-reply@ecoworkinc.com" }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.paperclip_defaults = Settings.environments.paperclip.default
  # {
  #   :storage => :s3,
  #   :s3_credentials => {
  #     :bucket => 's3-pcloud-test',
  #     :access_key_id => 'AKIAJS52YFZUARWCSMVQ',
  #     :secret_access_key => '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'
  #   }
  # }
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.add_footer = true
  end
end

# RailsAdmin.config do |config|

#   ### Popular gems integration

#   # == Devise ==
#   config.authenticate_with do
#     warden.authenticate! scope: :user
#   end
#   config.current_user_method(&:current_user)

#   ## == Cancan ==
#   # config.authorize_with :cancan

#   ## == PaperTrail ==
#   # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

#   ### More at https://gipwdthub.com/sferik/rails_admin/wiki/Base-configuration

#   config.actions do
#     dashboard                     # mandatory
#     index                         # mandatory
#     new
#     export
#     bulk_delete
#     show
#     edit
#     delete
#     show_in_app

#     ## With an audit adapter, you can add:
#     # history_index
#     # history_show
#   end
# end
