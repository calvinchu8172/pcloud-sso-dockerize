Given(/^an existing user's account and password$/) do
  @user = FactoryGirl.create(:api_user,
    email: "acceptance@ecoworkinc.com",
    password: "secret123",
    password_confirmation: "secret123")
end

When(/^client send a POST request to \/user\/1\/token with:$/) do |table|
  data = table.rows_hash
  path = path = '//' + Settings.environments.api_domain + "/user/1/token"

  id = data["id"]
  password = data["password"]
  certificate_serial = @certificate.serial
  signature = create_signature(id, certificate_serial)

  post path, {
    id: id,
    password: password,
    certificate_serial: certificate_serial,
    signature: signature,
    app_key: data["app_key"],
    os: data["os"]
  }
end

Then(/^the JSON response should include:$/) do |attributes|
  body_hash = JSON.parse(last_response.body)
  attributes = JSON.parse(attributes)

  attributes.each do |attribute|
    expect(body_hash.key?(attribute)).to be true
  end
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

# Given(/^an existing user's account and password but account is locked$/) do
#   @user = FactoryGirl.create(:api_user,
#     email: "acceptance@ecoworkinc.com",
#     password: "secret123",
#     password_confirmation: "secret123")

# end
