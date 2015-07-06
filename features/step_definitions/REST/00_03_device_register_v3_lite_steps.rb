When(/^the device send information to REST API \/d\/3\/register\/lite$/) do
  path = '//' + Settings.environments.api_domain + '/d/3/register/lite'
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

When(/^the device send reset request to REST API \/d\/3\/register\/lite$/) do
  create_rest_pairing(@registered_device)
  @device["reset"] = 1
  steps %{ When the device send information to REST API /d/3/register/lite}
end