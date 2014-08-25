# Visit search page with a user
Given(/^a user visits search devices page$/) do
  @user = TestingHelper.create_and_signin
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
  @device_session = create_device_session
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




def create_device_session
  device = TestingHelper.create_device
  device_session = FactoryGirl.create(:device_session, device_id: device.id)
  device_session.save
  device_session
end