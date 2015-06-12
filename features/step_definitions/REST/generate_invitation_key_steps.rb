Given(/^a signed in client$/) do
  @user = TestingHelper.create_and_confirm(FactoryGirl.create(:api_user))
end

Given(/^an existing device with pairing signed in client$/) do
  @device = TestingHelper.create_device
  FactoryGirl.create(:pairing, user_id: @user.id, device_id: @device.id)
end

When(/^client send a POST request to "(.*?)" with:$/) do |url_path, table|

  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + url_path

  authentication_token = data["authentication_token"].include?("EXPIRED") ? "" : @user.create_authentication_token
  device_id = data["device_id"].include?("INVALID") ? "" : @device.encrypted_id
  post path, {
    cloud_id: @user.encoded_id,
    authentication_token: authentication_token,
    device_id: device_id,
    permission: data["permission"]
    }
end

Then(/^the response status should be "(.*?)"$/) do |status_code|
  expect(last_response.status).to eq(status_code.to_i)
end

Then(/^the JSON response should include valid invitation_key$/) do
  body = JSON.parse(last_response.body)
  expect(body["invitation_key"]).to eq(Invitation.first.key)
end

Then(/^the JSON response should include error code: "(.*?)"$/) do |error_code|
  body = JSON.parse(last_response.body)
  expect(body["error_code"]).to eq(error_code)
end

Then(/^the JSON response should include description: "(.*?)"$/) do |description|
  body = JSON.parse(last_response.body)
  expect(body["description"]).to eq(description)
end