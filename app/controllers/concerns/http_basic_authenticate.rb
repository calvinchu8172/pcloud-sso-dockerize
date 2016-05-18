module HttpBasicAuthenticate
  extend ActiveSupport::Concern

  included do

    http_basic_authenticate_with :name => Settings.oauth_applications.account, :password => Settings.oauth_applications.password

  end
end