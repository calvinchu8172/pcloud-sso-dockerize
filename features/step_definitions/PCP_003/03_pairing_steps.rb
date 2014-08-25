# Set a user have device session and visit pairing page
Given(/^a user visit device's pairing page$/) do
	@user = TestingHelper.create_and_signin
	@device_id = TestingHelper.create_device_session.device_id
  visit "/discoverer/check/#{@device_id}"
end

# -------------------------------------------------------------------
# ---------------------------    input   ----------------------------
# -------------------------------------------------------------------

When (/^the user pairing is start$/) do
	click_link I18n.t("labels.confirm")
end

When(/^the user pairing is not connection$/) do
	click_link I18n.t("labels.confirm")
	@pair_statu = 'failure'
end

When(/^the user pairing is timeout$/) do
	click_link I18n.t("labels.confirm")
	@pair_statu = 'failure'
end

When(/^the user pairing is finished$/) do
	click_link I18n.t("labels.confirm")
	@pair_statu = 'done'
end

# -------------------------------------------------------------------
# ---------------------------   output   ----------------------------
# -------------------------------------------------------------------


Then(/^the user should see the countdown and pairing information$/) do
  expect(page).to have_selector('div.countdown')
  expect(page).to have_selector('div.zyxel_content > h2.zyxel_h2_icon1')
end

Then(/^the user should see pairing feature "(.*?)" message$/) do |msg|
	# sleep(5)
	ask('here')
	expect(page).to have_content(msg)
end

Then(/^the user will redirect to personal page$/) do
	expect(page.current_path).to eq(authenticated_root_path)
end



def set_pairing_status(status)
	@pairing_session = TestingHelper.create_pairing_session
	@pairing_session.user_id = @user.id
	@pairing_session.device_id = @device_id
	@pairing_session.status = status
end

def refresh
	visit [ current_path, page.driver.request.env['QUERY_STRING'] ].reject(&:blank?).join('?')
end