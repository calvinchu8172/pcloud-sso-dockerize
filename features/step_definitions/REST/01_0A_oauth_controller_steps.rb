When(/^oauth_controller call method: get_oauth_data$/) do
  controller = Api::User::OauthController.new
  @data_result = controller.get_oauth_data("facebook", @uuid, @access_token)
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
end
