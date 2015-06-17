Given(/^a user sign in from APP$/) do
  @user = TestingHelper.create_and_confirm(FactoryGirl.create(:api_user))
end

Given(/^a user try to request own device list from APP$/) do
  @device = TestingHelper.create_device
end

When(/^APP sent a GET request to "(.*?)" with:$/) do |url_path, table|
  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + url_path

  authentication_token = data["authentication_token"].include?("EXPIRED") ? "" : @user.create_authentication_token
  cloud_id = data["cloud_id"].include?("INVALID") ? "" : @user.encoded_id
  get path, {
    cloud_id: cloud_id,
    authentication_token: authentication_token
  }
end

Then(/^the HTTP response status should be "(.*?)"$/) do |status_code|
  expect(last_response.status).to eq(status_code.to_i)
end

Then(/^the JSON response should include$/) do |attributes|
  body_array = JSON.parse(last_response.body)
  attributes = JSON.parse(attributes)

  body_array.each do |body|
    attributes.each do |attribute|
      expect(attribute).to be true
    end
  end
end

Then(/^the responsed JSON should include error code: "(.*?)"$/) do |error_code|
  body = JSON.parse(last_response.body)
  expect(body["error_code"]).to eq(error_code)
end

Then(/^the responsed JSON should include description: "(.*?)"$/) do |description|
  body = JSON.parse(last_response.body)
  expect(body["description"]).to eq(description)
end