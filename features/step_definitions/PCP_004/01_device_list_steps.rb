# Set a user visit home page
Given(/^a user was signin and visits home page$/) do
	@user = TestingHelper.create_and_signin
end

# -------------------------------------------------------------------
# ---------------------------    input   ----------------------------
# -------------------------------------------------------------------

When(/^the user have not paired devices$/) do
	visit authenticated_root_path
end

When(/^the user have already paired device$/) do
	@pairing = TestingHelper.create_pairing(@user.id)
	visit authenticated_root_path
end

# -------------------------------------------------------------------
# ---------------------------   output   ----------------------------
# -------------------------------------------------------------------

# check user in search result page when user haven't pairing
Then(/^the user will redirect to Search Results page$/) do
	expect(page.current_path).to include('/discoverer/index')
end

# user should see device info and pairing link
Then(/^the user should see device list$/) do
	expect(page).to have_selector('.zyxel_table_style4, a[href*="/ddns/setting"]')
end

# user should see ddns not config message
Then(/^the user should see "(.*?)" message on My Devices page$/) do |msg|
	expect(page).to have_content(msg)
end
