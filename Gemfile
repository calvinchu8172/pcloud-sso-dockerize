source 'https://rubygems.org'

gem 'rails', '4.2.6'
gem 'rails-api'
gem 'rails-i18n'
gem 'rake', '10.4.2'


# -------------------- #
# -   for Database   - #
# -------------------- #

gem 'mysql2', '0.3.16'

group :development, :test do
  # for optimize database
  gem 'bullet'
end


# -------------- #
# -   for UI   - #
# -------------- #

gem 'select2-rails'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'angularjs-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'simple_form'
gem 'bootstrap-sass'
gem 'compass-rails'
gem 'c3-rails'
gem 'd3-rails'
gem 'i18n_country_select', '1.1.5'
gem 'i18n-country-translations', '1.2.2'

source 'https://rails-assets.org' do
  gem 'rails-assets-angular-timer', '1.2.1'
  gem 'rails-assets-ng-table', '0.3.2'
  gem 'rails-assets-jqlite'
  gem 'rails-assets-jquery-entropizer', '0.1.0'
  gem 'rails-assets-entropizer', '0.1.3'
end


# ----------------- #
# -   for Debug   - #
# ----------------- #

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
  gem 'spring'
  gem 'quiet_assets'
end

# Display full error content
group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'web-console', '~> 2.0'
end


# ------------------- #
# -   for BDD Test  - #
# ------------------- #

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
  gem 'letter_opener'
  gem 'action_mailer_cache_delivery'
end


# --------------- #
# -   for DOC   - #
# --------------- #

group :development, :test do
  gem 'yard'
  gem 'yard-cucumber'
  gem 'redcarpet'
  gem 'github-markup'
end


# ---------------- #
# -   for Model  - #
# ---------------- #

gem 'immigrant', '~> 0.1'
gem 'redis-objects'
gem 'attr_encrypted', '1.3.0'


# ------------- #
# -   Tools   - #
# ------------- #

group :development, :test do
  gem 'i18n-docs'
  gem 'sdoc', '~> 0.4.0'
  gem 'faker'
end

gem 'mail', '2.5.4'
gem 'devise', '3.5.1'
gem 'devise-i18n'
gem 'log4r'
gem 'xmpp4r'
gem 'fluent-logger'
gem 'rails_config'
gem 'unicorn'
gem 'omniauth'
gem 'omniauth-oauth2', '1.3.1'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'
gem 'recaptcha', '~> 0.3.6', require: 'recaptcha/rails'
gem 'paperclip', github: 'thoughtbot/paperclip'
gem 'rmagick'
gem 'aws-sdk', '~> 1'
gem 'rails_admin', group: [:test, :development, :staging]
gem 'rest-client'
gem 'json', '1.8.2'
gem 'browser-timezone-rails'
gem 'whenever', '~> 0.9.4', require: false
gem 'time_difference'
gem 'doorkeeper'
# gem 'doorkeeper-i18n'

group :development do
  gem 'brakeman', require: false
end
