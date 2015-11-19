When(/^the device send information to REST API \/d\/3\/register$/) do
  path = '//' + Settings.environments.api_domain + '/d/3/register'
  signature = create_signature(
    @certificate.serial,
    @device["mac_address"],
    @device["serial_number"],
    @device["model_name"],
    @device["firmware_version"])

  @device["signature"] = signature unless @invalid_signature
  @device["certificate_serial"] = @certificate.serial
  post path, @device
end

When(/^the device send reset request to REST API \/d\/3\/register$/) do
  create_rest_pairing(@registered_device)
  @device["reset"] = 1
  steps %{ When the device send information to REST API /d/3/register}
end

Given(/^the device has a DDNS record, and ip is "(.*?)"$/) do |ip|
  Domain.find_or_create_by(domain_name: Settings.environments.ddns)
  TestingHelper.create_ddns(Device.first, ip)
end

Given(/^the device IP was be changed to "(.*?)"$/) do |ip|
  ENV['RAILS_TEST_IP_ADDRESS'] = ip
end

Then(/^DDNS ip should be update to "(.*?)"$/) do |ip|
  expect(Ddns.first.ip_address).to eq(ip)
end

Then(/^XmppLast should record this device register sign in time$/) do
  username = Api::Device.first.xmpp_username
  expect(XmppLast.find_by(username: username).last_signin_at).to be_present
end

Then(/^the database should have no any association data with this device, including Invitation and AcceptedUser$/) do

end

Then(/^the ip in device session should be the same as "(.*?)"$/) do |ip|
  expect(Device.first.session['ip']).to eq(ip)
end







