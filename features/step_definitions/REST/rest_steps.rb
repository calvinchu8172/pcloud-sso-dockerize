Given(/^the device with information$/) do |table|
	@device = table.rows_hash
end

When(/^the device POST to "(.*?)"$/) do |path|
	path = 'http://127.0.0.1:3000' + path
	post path, @device
end

When(/^the device already registration$/) do
	steps %{
		When the device POST to "/d/1/register"
		Then the HTTP will return 200 
	}
end

When(/^the device "(.*?)" was be changed to "(.*?)"$/) do |key, value|
	@device["#{key}"] = value
	reset_signature(@device)
	steps %{
		When the device POST to "/d/1/register"
	}
end	

Then(/^the HTTP will return (\d+)$/) do |response|
	expect(last_response.status).to eq(response.to_i)

	@result = JSON.parse(last_response.body)
	# puts JSON.pretty_generate(@result)
	check_rest_result_valid(@device, @result)
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

	expect(xmpp_username).to eq(result["xmpp_account"])
	expect(Settings.xmpp.bots).to eq(result["xmpp_bots"])
	expect(Settings.xmpp.nodes).to eq(result["xmpp_ip_addresses"])
end