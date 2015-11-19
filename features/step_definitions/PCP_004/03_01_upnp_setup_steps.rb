Given(/^a user visit UPnP setup page with module version 1 device$/) do
  @user = TestingHelper.create_and_signin
  @pairing = TestingHelper.create_pairing(@user.id)
  @pairing.device.module_version['upnp'] = 1
  @module_version = @pairing.device.module_version['upnp']
  # visit upnp_path(@pairing.device.encoded_id)
  visit "/#{@module_version}/upnp/#{@pairing.device.encoded_id}"
end