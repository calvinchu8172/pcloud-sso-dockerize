# Visit search page with a user
Given(/^a user visits search devices page$/) do
  @user = TestingHelper.create_and_signin
end

# Set a user have not device
When(/^the device didn't connection$/) do
  visit '/discoverer/index'
end

# Set a user have a device
When(/^the device connect$/) do
	@user
  device_session = TestingHelper.create_device_session
  visit '/discoverer/index'
end

Then(/^the user should not see devices list$/) do
  expect(page).to_not have_selector('table.devices_list .device, a[href*="/discoverer/check"]')
end

Then(/^the user should see devices list$/) do
  expect(page).to have_selector('table.devices_list .device, a[href*="/discoverer/check"]')
end
