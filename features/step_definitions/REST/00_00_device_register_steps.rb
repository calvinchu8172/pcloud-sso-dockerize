
# ----------------------- #
# -------- steps -------- #
# ----------------------- #

When(/^the device send "(.*?)" request to REST API \/d\/1\/register$/) do |action|
  @device_given_attrs["reset"] = 1 if action == "reset"

  # Create pairing data of registered device if device is registered.
  # To understand the variable @is_device_registered, please steps check api_common_steps.rb:
  # * Given the device is registered
  # * Given the device is not registered
  if @is_device_registered
    create_rest_pairing(@registered_device)
  end 

  # Call register API
  path = '//' + Settings.environments.api_domain + '/d/1/register'
  post path, @device_given_attrs
end

# --------------------------- #
# -------- functions -------- #
# --------------------------- #
