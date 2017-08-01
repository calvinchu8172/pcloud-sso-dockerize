class AddLogoutRedirectUriToOauthApplication < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :logout_redirect_uri, :text
  end
end
