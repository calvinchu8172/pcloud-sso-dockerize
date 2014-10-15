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

When(/^the device firmware_version was be changed to "(.*?)"$/) do |value|
	@device["firmware_version"] = value
	get_signature(@device)
	steps %{
		When the device POST to "/d/1/register"
	}
end

When(/^the device serial_number was be changed to "(.*?)"$/) do |value|
	@device["serial_number"] = value
	get_signature(@device)
	steps %{
		When the device POST to "/d/1/register"
	}
end

When(/^the device mac_address was be changed to "(.*?)"$/) do |value|
	@device["mac_address"] = value
	get_signature(@device)
	steps %{
		When the device POST to "/d/1/register"
	}
end	

Then(/^the HTTP will return (\d+)$/) do |response|
	expect(last_response.status).to eq(response.to_i)
end

def get_signature(device)
	magic_number = Settings.magic_number
	data = device[:mac_address] + device[:serial_number].to_s + device[:model_name] + device[:firmware_version] + magic_number.to_s
	sha224 = OpenSSL::Digest::SHA224.new
  @device[:signature] = sha224.hexdigest(data)
  @device[:signature]
end  
