Given(/^a user choose a device$/) do
  Capybara.session_name = "User1"
  @user = TestingHelper.create_and_signin
  @device = TestingHelper.create_device
end

Given(/^the user will redirect to pairing page$/) do
  visit "/discoverer/check/#{@device.id}"
end

Given(/^the user completely pairing a device$/) do
  steps %{
    When the user click "Confirm" button to start pairing
    And the user click the copy button of device within 10 minutes
    Then the user should see "Successfully paired." message on pairing page
    When the user click "Confirm" button when finished pairing
  }
end

Given(/^another user2 in progress paired for the same device$/) do
  # switch to new bowser user2
  Capybara.session_name = "User2"
  @user2 = TestingHelper.create_and_signin
  visit "/discoverer/check/#{@device.id}"
  click_link "Confirm"
  # switch to user1
  Capybara.session_name = "User1"
end

# -------------------------------------------------------------------
# -------------------------- User behavior --------------------------
# -------------------------------------------------------------------

When(/^the user have other device$/) do
  @device2 = TestingHelper.create_device
end

When(/^complete the pairing process$/) do
  click_link "Confirm"
  @pairing_session = get_pairing_session(@device2)
  pairing_session_behavior(@pairing_session, "waiting", @device2)
  pairing_session_behavior(@pairing_session, "done", @device2)
  sleep 15
end

When(/^the user unpairing this device$/) do
  visit "/personal/index"
  expect(page).to have_link "Unpairing", href: "/unpairing/index/#{@pairing.id}"

  click_link("Unpairing", :href => "/unpairing/index/#{@pairing.id}")
  expect(page).to have_content I18n.t("warnings.settings.unpairing.instruction")
  expect(page).to have_link I18n.t("labels.confirm")
  expect(page).to have_link I18n.t("labels.cancel")
  click_link "Confirm"
  expect(page.current_path).to eq "/unpairing/success/#{@device.id}"
end

When(/^the user visits Search Devices page$/) do
  visit "/discoverer/index"
end

When(/^the user click "(.*?)" button to start pairing$/) do |link|
  click_link link
  @pairing_session = get_pairing_session(@device)
end

When(/^the device was connection$/) do
  pairing_session_behavior(@pairing_session, "waiting", @device)
end

When(/^the device was not connection$/) do
  pairing_session_behavior(@pairing_session, "offline", @device)
end

When(/^the user did not click on the copy button of device within (\d+) minutes$/) do |arg1|
  pairing_session_behavior(@pairing_session, "failure", @device)
end

When(/^the user click the copy button of device within (\d+) minutes$/) do |arg1|
  pairing_session_behavior(@pairing_session, "done", @device)
  sleep 15
end

When(/^the device was connection and pairing process is waiting$/) do
  steps %{
    When the user click "Confirm" button to start pairing
    Then the user should see "Connecting" message on pairing page
  }
end

When(/^the user click "(.*?)" button when finished pairing$/) do |link|
  @pairing = FactoryGirl.create(:pairing, user_id: @user.id, device_id: @device.id)
  wait_server_response
  click_link link
end

When(/^the user click "(.*?)" link to start pairing$/) do |link|
  click_link "Pairing", href: "/discoverer/check/#{@device2.id}"
end

# -------------------------------------------------------------------
# -------------------------- Expect result --------------------------
# -------------------------------------------------------------------

Then(/^the user should see another devices$/) do
  expect(page).to have_link "Pairing", href: "/discoverer/check/#{@device2.id}"
end

Then(/^the user will see the error message about device is pairing$/) do
  expect(page).to have_content("device is pairing")
end

Then(/^the user should find the device after unpairing$/) do
  expect(page).to have_link "Pairing", href: "/discoverer/check/#{@device.id}"
end

Then(/^the user will redirect to Search Devices page$/) do
  expect(page.current_path).to eq "/discoverer.format"
end

Then(/^the user will see the confirm message about cancel Pairing flow$/) do
  expect(page).to have_content I18n.t("warnings.settings.pairing.cancel_instruction")
end

Then(/^the user should see "(.*?)" message on pairing page$/) do |msg|
  expect(page).to have_content(msg)
end

Then(/^the user should see the pairing information$/) do
  expect(page).to have_content(I18n.t("warnings.settings.pairing.start.instruction"))
end

Then(/^the user will redirect to DDNS setup page$/) do
	expect(page.current_path).to eq("/ddns/setting/#{@device.id}")
end

Then(/^the user will go back to Pairing setup flow$/) do
  steps %{
    Then it should not do anything on Pairing page
  }
end

Then(/^it should not do anything on Pairing page$/) do
  expect(page).to have_content I18n.t("warnings.settings.pairing.connecting")
end

def get_pairing_session(device)
	device.pairing_session.all
end

def pairing_session_behavior(pairing_session, status, device)
	pairing_session['status'] = status
  if (status == 'waiting')
    pairing_session['waiting_expire_at'] = (Time.now() + 10.minutes).to_i
  end
  device.pairing_session.update(pairing_session)
	wait_server_response
	pairing_session
end