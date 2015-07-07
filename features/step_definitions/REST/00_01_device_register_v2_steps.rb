Given(/^the device module information$/) do
  @device["module"] = '[{"name": "DDNS", "ver": "1" }, {"name": "pairing", "ver": "button"}]'
end

When(/^the device send information to REST API \/d\/2\/register$/) do
  path = '//' + Settings.environments.api_domain + '/d/2/register'
  post path, @device
end

When(/^the device send reset request to REST API \/d\/2\/register$/) do
  create_rest_pairing(@registered_device)
  @device["reset"] = 1
  steps %{ When the device send information to REST API /d/2/register}
end

Then(/^the module record in database as expected$/) do
  expect(Device.first.module_version.all).to eq({"ddns" => "1", "pairing" => "button"})
end
