When(/^client send a POST request to \/user\/1\/token with:$/) do |table|
  data = table.rows_hash
  path = path = '//' + Settings.environments.api_domain + "/user/1/token"

  id = data["id"]
  password = data["password"]
  uuid = data["uuid"]
  certificate_serial = @certificate.serial
  signature = create_signature(id, certificate_serial, uuid)

  post path, {
    id: id,
    password: password,
    uuid: uuid,
    certificate_serial: certificate_serial,
    signature: signature,
    app_key: data["app_key"],
    os: data["os"]
  }
end

Then(/^the client should be using other$/) do
  user_token = Api::User::Token.first
  expect(user_token.app_info[:os]).to eq("0")
end

Then(/^the client's mobile app key should be "(.*?)"$/) do |key|
  user_token = Api::User::Token.first
  expect(user_token.app_info[:app_key]).to eq(key)
end

Then(/^the client should be using iOS$/) do
  user_token = Api::User::Token.first
  expect(user_token.app_info[:os]).to eq("1")
end

Then(/^the client should be using Android$/) do
  user_token = Api::User::Token.first
  expect(user_token.app_info[:os]).to eq("2")
end

Given(/^an existing user's account and password but have not confirmed yet longer than (\d+) days$/) do |day_count|
  @user = FactoryGirl.create(:api_user,
    email: "acceptance@ecoworkinc.com",
    password: "secret123",
    password_confirmation: "secret123")
  @user.update_attribute(:created_at, Time.now - day_count.to_i*24*60*60)
end

When(/^record the first xmpp account$/) do
  result = JSON.parse(last_response.body)
  @first_xmpp_account = result["xmpp_account"]["id"]
end

Then(/^the second xmpp account is different with the first one$/) do
  expect(@first_xmpp_account).to be_present

  result = JSON.parse(last_response.body)
  second_xmpp_account = result["xmpp_account"]["id"]
  expect(second_xmpp_account).not_to eq(@first_xmpp_account)
end

# Given(/^an existing user's account and password but account is locked$/) do
#   @user = FactoryGirl.create(:api_user,
#     email: "acceptance@ecoworkinc.com",
#     password: "secret123",
#     password_confirmation: "secret123")

# end
