source 'https://rubygems.org'

gem 'rails', '4.2.7.1'
gem 'rails-api'
gem 'rails-i18n'
gem 'rake', '10.4.2'

# ---------------- #
# - for Database - #
# ---------------- #

gem 'mysql2', '0.4.5'

group :development do
  # for optimize database
  gem 'bullet'
end

# ------------- #
# - for Debug - #
# ------------- #

group :development, :test do
  gem 'pry'
  gem 'pry-remote'
  gem 'pry-rails'
  # 優化 console 顯示
  gem 'awesome_print', require: false
  gem 'hirb', require: false
  gem 'hirb-unicode', require: false
  # rails 4 tools
  gem 'byebug'
end

group :development do
  # Display full error content
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  # rails 4 tools
  gem 'web-console', '~> 2.0'
  gem 'spring'
end

# ---------------- #
# - for BDD Test - #
# ---------------- #

# Use Cucumber test framwork
group :test do
  gem 'cucumber-rails', require: false
  gem 'capybara'
  gem 'capybara-webkit', '~> 1.7'
  gem 'database_cleaner'
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails'
  gem 'email_spec'
  # Use SimpleCov test Cucumber coverage
  gem 'simplecov', require: false
  gem 'rack_session_access'
  gem 'action_mailer_cache_delivery'
  gem 'timecop', '0.8.1'
end

# ----------- #
# - for DOC - #
# ----------- #

group :development, :test do
  gem 'yard'
  gem 'yard-cucumber'
  gem 'redcarpet'
  gem 'github-markup'
end

# ------------- #
# - for Model - #
# ------------- #

gem 'immigrant', '~> 0.1'
gem 'redis-objects'
gem 'attr_encrypted', '1.3.0'

# -------------- #
# - for Logger - #
# -------------- #

gem 'log4r'
gem 'fluent-logger'
gem 'quiet_assets'

# --------- #
# - Tools - #
# --------- #

group :development, :test do
  gem 'i18n-docs'
  gem 'sdoc', '~> 0.4.0'
  gem 'faker'
end

group :development do
  gem 'letter_opener'
end

gem 'devise', '3.5.1'
gem 'devise-i18n'
gem 'xmpp4r'
gem 'rails_config'
gem 'unicorn'
gem 'omniauth'
gem 'omniauth-oauth2', '>= 1.6'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2', '>= 0.8.0'
gem 'recaptcha', '~> 3.3.0', require: 'recaptcha/rails'
gem 'paperclip'
gem 'aws-sdk', '~> 1'
gem 'json', '1.8.2'
gem 'doorkeeper'
gem 'hamlit'
gem 'redis-rails'

group :development do
  gem 'brakeman', require: false
end

# ---------- #
# - for UI - #
# ---------- #

gem 'select2-rails'
gem 'font-awesome-rails', '4.6.3.1'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'simple_form', '3.2.1'
gem 'bootstrap-sass'
gem 'compass-rails'
gem 'i18n_country_select', '1.1.5'
gem 'i18n-country-translations', '1.2.2'
gem 'browser-timezone-rails', '1.0.1'

source 'https://rails-assets.org' do
  gem 'rails-assets-jquery-entropizer', '0.1.0'
  gem 'rails-assets-entropizer', '0.1.3'
end
