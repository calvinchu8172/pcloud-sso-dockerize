Given(/^an user exists$/) do
   @user = FactoryGirl.create(:user)
   @user.skip_confirmation!
   @user.save
   @cloud_id = @user.encoded_id
end

Given(/^an device exists$/) do
  TestingHelper::create_product_table if Product.count == 0
  @device = FactoryGirl.create(:device, product_id: 30)
end

Given(/^the device paired with the user$/) do
  @pairing = FactoryGirl.create(:pairing, user_id: @user.id, device_id: @device.id)
end

Given(/^an client app exists$/) do
  # 這裡有 bug，一定要先打一個連結，之後 post 才不會有 undefined method "call" 的錯誤
  get '//' + Settings.environments.api_domain
  @app = FactoryGirl.create(:oauth_client_app)
end

When(/^device sends a POST request to "(.*?)" with:$/) do |path, table|
  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + path

  if data["app_id"].nil?
    app_id = nil
  elsif data["app_id"].include?("INVALID")
    app_id = "invalid app_id"
  else
    app_id = @app.uid
  end

  if data["certificate_serial"].nil?
    certificate_serial = nil
  elsif data["certificate_serial"].include?("INVALID")
    certificate_serial = "invalid certificate_serial"
  else
    certificate_serial = @certificate.serial
  end

  if data["cloud_id"].nil?
    cloud_id = nil
  elsif data["cloud_id"].include?("INVALID")
    cloud_id = "invalid cloud_id"
  else
    cloud_id = @cloud_id
  end

  if data["mac_address"].nil?
    mac_address = nil
  elsif data["mac_address"].include?("INVALID")
    mac_address = "invalid mac_address"
  else
    mac_address = @device.mac_address
  end

  if data["serial_number"].nil?
    serial_number = nil
  elsif data["serial_number"].include?("INVALID")
    serial_number = "invalid serial_number"
  else
    serial_number = @device.serial_number
  end

  if data["signature"].nil?
    signature = nil
  elsif data["signature"].include?("INVALID")
    signature = "invalid signature"
  else
    signature = create_signature(app_id, certificate_serial, cloud_id, mac_address, serial_number)
  end

  header 'X-Signature', signature

  body = {
    app_id: app_id,
    certificate_serial: certificate_serial,
    cloud_id: cloud_id,
    mac_address: mac_address,
    serial_number: serial_number
  }

  body.delete_if {|key, value| value.nil? }

  post path, body
end

Then(/^the JSON response should include access_token and refresh_token:$/) do |table|
  token = Doorkeeper::AccessToken.find_by_application_id(@app.id)
  data = table.rows_hash
  body_hash = JSON.parse(last_response.body)

  expect(body_hash.key?('data')).to be true
  data.each do |key, value|
    expect(body_hash["data"].key?(key)).to be true
  end

  expect(body_hash["data"]["access_token"]).to eq token.token
  expect(body_hash["data"]["token_type"]).to eq "bearer"
  expect(body_hash["data"]["expires_in"]).to eq token.expires_in
  expect(body_hash["data"]["refresh_token"]).to eq token.refresh_token
  expect(body_hash["data"]["created_at"]).to eq token.created_at.to_i

end

When(/^the device is not paired$/) do
  Pairing.find_by_user_id(@user.id).destroy
end
