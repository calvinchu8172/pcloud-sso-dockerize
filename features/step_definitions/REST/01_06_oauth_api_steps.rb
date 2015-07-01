Given(/^the user having password "(.*?)"$/) do |password|
  @password = password
end

When(/^the device send information to facebook oauth register API$/) do

  path = '//' + Settings.environments.api_domain + "/user/1/register/facebook"

  signature = create_signature(@certificate.serial, @uuid, @access_token)

  post path, {
    user_id: @uuid,
    access_token: @access_token,
    password: @password,
    certificate_serial: @certificate.serial,
    signature: signature
  }
end

Then(/^the API should return "(.*?)" error code and "(.*?)" message$/) do |error_code, message|
  response = JSON.parse(last_response.body)
  expect(response["error_code"]).to eq(error_code)
  expect(response["description"]).to eq(message)
end

When(/^the device send information to facebook oauth checkin API$/) do
  path = '//' + Settings.environments.api_domain + "/user/1/checkin/facebook"

  get path, {
    user_id: @uuid,
    access_token: @access_token
  }

end

Then(/^the API should return user token message$/) do
  response = JSON.parse(last_response.body)
  expect(response["account_token"]).to be_present
end

When(/^the device send information to google oauth register API$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^the user having APP account from facebook already$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the API should return "(.*?)" message and email account$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given(/^the user having APP account from google already$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^the device send information to google oauth checkin API$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^the user having access token and uuid from Google$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^the device send information to "(.*?)" oauth checkin API$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

When(/^the device send information to "(.*?)" oauth register API$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given(/^a user using the same email to register facebook portal oauth account already$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^a user using the same email to register google portal oauth account already$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^the user having invalid access token and uuid from Facebook$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the API should return "(.*?)" error message$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given(/^the user already checkin from Facebook$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^the user having certificate_serial <abcde>$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the user having password <invalid_password>$/) do
  pending # express the regexp above with the code you wish you had
end