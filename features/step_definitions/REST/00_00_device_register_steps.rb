# -------------------------------------------------------------------
# ---------------------------    input   ----------------------------
# -------------------------------------------------------------------

Given(/^the device with information$/) do |table|
  TestingHelper::create_product_table if Product.count == 0
  @device = table.rows_hash
  reset_signature(@device)
end

# When(/^the device POST to "(.*?)"$/) do |path|
When(/^the device send information to REST API \/d\/1\/register$/) do
  path = '//' + Settings.environments.api_domain + '/d/1/register'
  post path, @device
end

Given(/^the device already registration$/) do
  @registered_device = Device.checkin(@device.symbolize_keys)
end

When(/^the device send reset request to REST API \/d\/1\/register$/) do
  create_rest_pairing(@registered_device)
  @device["reset"] = 1
  steps %{ When the device send information to REST API /d/1/register}
end

When(/^the device "(.*?)" was be changed to "(.*?)"$/) do |key, value|
  @device["#{key}"] = value
  reset_signature(@device)
end

When(/^the device signature was be changed to "(.*?)"$/) do |value|
  @device["signature"] = value
  @invalid_signature = true
end

When(/^the device IP was be changed$/) do
  ENV['RAILS_TEST_IP_ADDRESS'] = '1.2.3.4'
end


# -------------------------------------------------------------------
# ---------------------------   output   ----------------------------
# -------------------------------------------------------------------

Then(/^the API should return success respond$/) do
  expect(last_response.status).to eq(200)
end

Then(/^the databases should have not pairing record$/) do
  device_id = Device.find_by(mac_address: @device["mac_address"]).id
  expect(Pairing.find_by(device_id: device_id)).to be_nil
end

Then(/^the record in databases as expected$/) do
  @result = JSON.parse(last_response.body)
  check_rest_result_valid(@device, @result)
end

Then(/^the database does not have record$/) do
  name = 'd' + @device["mac_address"].gsub(':', '-') + '-' + @device["serial_number"].gsub(/([^\w])/, '-')
  xmpp_username = name + '@' + Settings.xmpp.server + "/" + Settings.xmpp.device_resource_id
  expect(XmppUser.find_by(username: xmpp_username)).to be_nil
end

Then(/^the API should return "(.*?)" and "(.*?)" with failure responds$/) do |http, json|
  @result = JSON.parse(last_response.body)
  expect(last_response.status).to eq(http.to_i)
  expect(@result["result"]).to eq(json)
end

Then(/^the API should return "(.*?)" and "(.*?)" with error responds$/) do |http, json|
  @result = JSON.parse(last_response.body)
  expect(last_response.status).to eq(http.to_i)
  expect(@result["error"]).to eq(json)
end

# -------------------------------------------------------------------
# --------------------------   function   ---------------------------
# -------------------------------------------------------------------

def reset_signature(device)
  magic_number = Settings.magic_number
  data = device["mac_address"] + device["serial_number"].to_s + device["model_name"] + device["firmware_version"] + magic_number.to_s
  sha224 = OpenSSL::Digest::SHA224.new
  @device["signature"] = sha224.hexdigest(data)
  @device
end

def check_rest_result_valid(device, result)
  name = 'd' + device["mac_address"].gsub(':', '-') + '-' + device["serial_number"].gsub(/([^\w])/, '-')
  xmpp_username = name + '@' + Settings.xmpp.server + "/" + Settings.xmpp.device_resource_id

  # Check json result
  expect(result["xmpp_account"]).to eq(xmpp_username)
  expect(result["xmpp_bots"]).to eq(Settings.xmpp.bots)
  expect(result["xmpp_ip_addresses"]).to eq(Settings.xmpp.nodes)

  # Check xmpp db record
  db_user = XmppUser.find_by(username: name)
  expect(db_user.username).to eq(name)
  expect(db_user.password).not_to be_empty

  # Check redis record
  redis = Redis.new
  device_id = redis.GET("xmpp:#{name}:session")
  device_session = Device.find(device_id).session.all
  expect(device_session["xmpp_account"]).to eq(name)
  # expect(request.remote_ip).to eq(device_session["ip"])

  if ENV['RAILS_TEST_IP_ADDRESS'].nil?
    expect(device_session["ip"]).to eq('127.0.0.1')
  else
    expect(device_session["ip"]).to eq(ENV['RAILS_TEST_IP_ADDRESS'])
  end

end


def create_rest_pairing(device)

  redis = Redis.new
  pairing = Pairing.new
  pairing.device = device
  pairing.user = TestingHelper.create_and_signin
  pairing.ownership = 0
  puts 'pairing:' + pairing.attributes.to_s
  pairing.save
end
