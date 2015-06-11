Given(/^a signed in client$/) do
  @user = Api::User.create(
    email: "personal@example.com",
    password: "12345678",
    password_confirmation: "12345678",
    edm_accept: "0",
    agreement: "1")
end

Given(/^an existing device with pairing signed in client$/) do
  @device = FactoryGirl.create(:device, product_id: Product.first.id)
  @pairing = FactoryGirl.create(:pairing, user_id: @user.id, device_id: @device.id)
end

When(/^client send a POST request to "(.*?)" with:$/) do |url_path, table|
  @device
  data = table.hashes.slice(0)
  path = '//' + Settings.environments.api_domain + url_path

  post path, {
    cloud_id: @user.encoded_id,
    authentication_token: @user.create_authentication_token,
    device_id: @device.encrypted_id,
    permission: data["permission"]
    }
end

Then(/^the response status should be "(.*?)"$/) do |status_code|
  expect(last_response.status).to eq(status_code.to_i)
end

Then(/^the JSON response should be:$/) do |response_body|
  expect(JSON.parse(last_response.body)).to eq(response_body)
end