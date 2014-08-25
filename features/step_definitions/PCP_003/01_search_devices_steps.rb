# Visit search page with a user
Given(/^a user visits search devices page$/) do
  @user = TestingHelper.create_and_signin
  @device_session = TestingHelper.create_device_session
  # @devices = TestingHelper.create_device
  visit '/discoverer/index'
end

# Set a user have not device
When(/^the user have not any devices$/) do
	@user
end

# Set a user have a device
When(/^the user have a device$/) do
	@user
  @device_session
  find('.icon_research').click
  # ask('does that look right?')  # wait for check browser
end

Then(/^the user should not see search devices feature devices list$/) do
  expect(page).to_not have_selector('.device.ng-scope')
end

Then(/^the user should see search devices feature devices list$/) do
  expect(page).to have_selector('.device.ng-scope')
  # puts page.body
end
