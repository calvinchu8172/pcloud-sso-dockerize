When(/^oauth_controller call method: get_oauth_data$/) do
  controller = Api::User::OauthController.new
  @data_result = controller.get_oauth_data(@provider, @uuid, @access_token)
end

Then(/^get_oauth_data should return valid data info$/) do
  expect(@data_result).to be_present
end

Then(/^get_oauth_data should return nil$/) do
  expect(@data_result).to be nil
end

Given(/^the client has invalid access token or uuid$/) do
  @uuid = ""
  @access_token = ""
  @provider = ["google_oauth2", "facebook"].sample
end

Given(/^the client update current access token and uuid from facebook$/) do
  access_token = JSON.parse(RestClient.get("https://graph.facebook.com/v2.3/oauth/access_token?client_id=#{Settings.oauth.facebook_app_id}&client_secret=#{Settings.oauth.facebook_secret}&grant_type=client_credentials"))
  access_token = access_token["access_token"]
  test_user = JSON.parse(RestClient.get("https://graph.facebook.com/#{Settings.oauth.facebook_app_id}/accounts/test-users", params: {access_token: access_token}))

  @access_token = test_user["data"].first["access_token"]
  @uuid = test_user["data"].first["id"]
  @provider = "facebook"
end
