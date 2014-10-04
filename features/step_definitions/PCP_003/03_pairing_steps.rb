Given(/^a user choose a device$/) do
	@user = TestingHelper.create_and_signin
  @device_session = TestingHelper.create_device_session
end

Given(/^the user will redirect to pairing page$/) do
  visit "/discoverer/check/#{@device_session.device_id}"
end

When(/^the user click "(.*?)" button to start pairing$/) do |link|
	click_link link
	@pairing_session = get_pairing_session(@user.id, @device_session.device_id)
end

When(/^the device was connection$/) do
	pairing_session_behavior(@pairing_session, "waiting")
end

When(/^the device was not connection$/) do
	pairing_session_behavior(@pairing_session, "offline")
end

When(/^the user did not click on the copy button of device within (\d+) minutes$/) do |arg1|
  pairing_session_behavior(@pairing_session, "failure")
end

When(/^the user click the copy button of device within (\d+) minutes$/) do |arg1|
	pairing_session_behavior(@pairing_session, "done")
	sleep 15
end

When(/^the user click "(.*?)" button when finished pairing$/) do |link|
	FactoryGirl.create(:pairing, user_id: @user.id, device_id: @device_session.device_id)
	wait_server_response
	click_link link
end

Then(/^the user should see "(.*?)" message on pairing page$/) do |msg|
  expect(page).to have_content(msg)
end

Then(/^the user should see the pairing information$/) do
  expect(page).to have_content(I18n.t("warnings.settings.pairing.start.instruction"))
end

Then(/^the user will redirect to DDNS setup page$/) do
	expect(page.current_path).to eq("/ddns/setting/#{@pairing_session.device_id}")
end

def get_pairing_session(user_id, device_id)
	pairing_session = PairingSession.where("device_id = ? and user_id = ?", device_id, user_id).last
end

def pairing_session_behavior(pairing_session, status)
	pairing_session.status = status
	pairing_session.save
	wait_server_response
	pairing_session
end