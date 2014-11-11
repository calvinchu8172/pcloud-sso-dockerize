# -------------------------------------------------------------------
# ---------------------------    input   ----------------------------
# -------------------------------------------------------------------

Given(/^the device with information$/) do |table|
  @device = table.rows_hash
end

# When(/^the device POST to "(.*?)"$/) do |path|
When(/^the device send information to REST API$/) do
  path = '//' + Settings.environments.api_domain + '/d/1/register'
  post path, @device
end

When(/^the device already registration$/) do
  steps %{
    When the device send information to REST API
    Then the API should return success respond
    And the record in databases as expected
  }
end

When(/^the device send reset request to REST API$/) do
  steps %{ When the device already registration }
  @device["reset"] = 1
  steps %{ When the device send information to REST API }
end

When(/^the device "(.*?)" was be changed to "(.*?)"$/) do |key, value|
  steps %{ When the device already registration }
  @device["#{key}"] = value
  reset_signature(@device)
  steps %{ When the device send information to REST API }
end

When(/^the device signature was be changed to "(.*?)"$/) do |value|
  @device["signature"] = value
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
  expect(xmpp_username).to eq(result["xmpp_account"])
  expect(Settings.xmpp.bots).to eq(result["xmpp_bots"])
  expect(Settings.xmpp.nodes).to eq(result["xmpp_ip_addresses"])

  # Check xmpp db record
  db_user = XmppUser.find_by(username: name)
  expect(name).to eq(db_user.username)
  expect(db_user.password).not_to be_empty

  # Check redis record
  redis = Redis.new
  device_id = redis.GET("xmpp:#{name}:session")
  device_session = Device.find(device_id).session.all
  expect(name).to eq(device_session["xmpp_account"])
  # expect(request.remote_ip).to eq(device_session["ip"])

end
