# -------------------------------------------------------------------
# ---------------------------    input   ----------------------------
# -------------------------------------------------------------------

Given(/^the device with information$/) do |table|
	@device = table.rows_hash
end

When(/^the device POST to "(.*?)"$/) do |path|
	path = '//' + Settings.environments.api_domain + path
	post path, @device
end

When(/^the device already registration$/) do
	steps %{
		When the device POST to "/d/1/register"
		Then the HTTP should return 200
	}
end

When(/^the device "(.*?)" was be changed to "(.*?)"$/) do |key, value|
	@device["#{key}"] = value
	reset_signature(@device)
	steps %{
		When the device POST to "/d/1/register"
	}
end

When(/^the device signature was be changed to "(.*?)"$/) do |value|
	@device["signature"] = value
	steps %{
		When the device POST to "/d/1/register"
	}
end


# -------------------------------------------------------------------
# ---------------------------   output   ----------------------------
# -------------------------------------------------------------------


Then(/^the HTTP should return (\d+)$/) do |response|
	expect(last_response.status).to eq(response.to_i)
end

Then(/^the HTTP should not return (\d+) and get json error code "(.*?)"$/) do |http, json|
	expect(last_response.status).to_not eq(http.to_i)
	@result = JSON.parse(last_response.body)
	expect(@result["error"]).to eq(json)
	# puts last_response.status
end

Then(/^the HTTP should not return (\d+) and get json result code "(.*?)"$/) do |http, json|
	expect(last_response.status).to_not eq(http.to_i)
	@result = JSON.parse(last_response.body)
	expect(@result["result"]).to eq(json)
	# puts last_response.status
end

Then(/^the record in databases as expected$/) do
	@result = JSON.parse(last_response.body)
	check_rest_result_valid(@device, @result)
	# puts last_response.status
end


def reset_signature(device)
	magic_number = Settings.magic_number
	data = device["mac_address"] + device["serial_number"].to_s + device["model_name"] + device["firmware_version"] + magic_number.to_s
	sha224 = OpenSSL::Digest::SHA224.new
  @device["signature"] = sha224.hexdigest(data)
  @device["signature"]
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
