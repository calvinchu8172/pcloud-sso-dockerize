Given(/^an oauth client user exists$/) do
  @oauth_client_user = FactoryGirl.create(:user)
end

Given(/^client user confirmed$/) do
  @oauth_client_user.confirmed_at = Time.now
  @oauth_client_user.save
end

Given(/^(\d+) existing client app and access token record$/) do |arg1|
  @oauth_client_app = FactoryGirl.create(:oauth_client_app)
  @oauth_access_token = FactoryGirl.create(:oauth_access_token, resource_owner_id: @oauth_client_user.id, application_id: @oauth_client_app.id, use_refresh_token: true)
end

When(/^client send a POST request to \/oauth\/token with:$/) do |table|

  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/oauth/token"

  # cloud_id = data["cloud_id"].include?("INVALID") ? "" : @user.encoded_id
  # authentication_token = check_authentication_token(data["authentication_token"])
  # certificate_serial = @certificate.serial

  # signature = create_signature(cloud_id, authentication_token, certificate_serial)
  # signature = "" if data["signature"].include?("INVALID")
  grant_type = data["grant_type"]
  if data["refresh_token"].include?("INVALID")
    refresh_token = "invalid refresh_token"
  else
    refresh_token = @oauth_access_token.refresh_token
  end
  client_id = @oauth_client_app.uid
  client_secret = @oauth_client_app.secret
  redirect_uri = @oauth_client_app.redirect_uri


  post path, {
    grant_type: grant_type,
    refresh_token: refresh_token,
    client_id: client_id,
    client_secret: client_secret,
    redirect_uri: redirect_uri
  }
end

Given(/^client user did not confirmed and the trial period has been expired (\d+) days$/) do |days|
  @oauth_client_user.created_at = @oauth_client_user.created_at - 4.days
  @oauth_client_user.save
end