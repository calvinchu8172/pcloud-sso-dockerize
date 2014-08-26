# Set a user visit home page
Given(/^a user is registered and visits home page$/) do
	@user = TestingHelper.create_and_signin
	visit '/'
end

# -------------------------------------------------------------------
# ---------------------------    input   ----------------------------
# -------------------------------------------------------------------

When(/^the user didn't paired any devices$/) do
  @user
end

When(/^the user have device$/) do
	@user
	@device_session = TestingHelper.create_device_session
	visit(page.current_path)	# Refresh
end

# -------------------------------------------------------------------
# ---------------------------   output   ----------------------------
# -------------------------------------------------------------------

# check user in search result page when user haven't pairing
When(/^the user will redirect to Search Results page$/) do
	expect(page.current_path).to include('/discoverer/index')
	puts page.current_path
end

# user should see device info and pairing link
Then(/^the user should see device list$/) do
	expect(page).to have_selector('table.devices_list .device, a[href*="/discoverer/check"]')
end

# user should see ddns not config message
Then(/^the user should see "(.*?)" message in My Devices page$/) do |msg|
	visit '/personal/index'
	expect(page).to have_content(msg)
end


