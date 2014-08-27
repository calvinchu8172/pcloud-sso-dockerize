# Visit search page with a user
Given(/^a user visits search devices page$/) do
  @user = TestingHelper.create_and_signin
  visit '/discoverer/index'
end

# Set a user have not device
When(/^the user have not any devices$/) do
  visit(page.current_path)  # Refresh
  ask('wait?')
end

# Set a user have a device
When(/^the user have a device$/) do
	@user
  device_session = TestingHelper.create_device_session
  visit(page.current_path)  # Refresh
end

Then(/^the user should not see devices list$/) do
  expect(page).to_not have_selector('table.devices_list .device, a[href*="/discoverer/check"]')
end

Then(/^the user should see devices list$/) do
  expect(page).to have_selector('table.devices_list .device, a[href*="/discoverer/check"]')
end
