Given(/^a user register a device$/) do
  @user = TestingHelper.create_and_signin
  @device_session = TestingHelper.create_device_session
  @device = @device_session.device
end

# -------------------------------------------------------------------
# ---------------------------    input   ----------------------------
# -------------------------------------------------------------------

Then(/^the user visit ddns setup page$/) do
	visit "/ddns/setting/#{@device.id}"
end

When(/^the user filled the valid hostname$/) do
	submit_hostname('valid')
end

When(/^the user filled the invalid hostname$/) do
	submit_hostname('!aa')
end

When(/^the user filled the registered hostname$/) do
	submit_hostname('zyxel')
end

When(/^the user update ddns setting failed$/) do
	ddns_session = create_ddns_session_status(@device.id, 'failure', 'failure')
	visit "/ddns/success/#{ddns_session.id}"
	wait_server_response
end

When(/^the user update ddns setting success$/) do
	ddns_session = create_ddns_session_status(@device.id, 'success', 'success')
	visit "/ddns/success/#{ddns_session.id}"
	wait_server_response
end

When(/^the user have new device and finished ddns setting$/) do
	ddns_session = create_ddns_session_status(@device.id, 'new_device', 'success')
	page.set_rack_session(first_pairing: true)
	page.visit "/ddns/success/#{ddns_session.id}"
	wait_server_response
end

Then(/^the user click confirm in ddns setting$/) do
	click_link I18n.t("labels.confirm")
end

# -------------------------------------------------------------------
# ---------------------------   output   ----------------------------
# -------------------------------------------------------------------


Then(/^the user should see hostname "(.*?)" error message$/) do |msg|
	expect(page.current_path).to include('/ddns/setting/')
	expect(page).to have_selector('div.zyxel_arlert_area > span')
	expect(page).to have_content(msg)
	puts 'Hostname ' + find('div.zyxel_arlert_area > span').text
end

Then(/^the user should see ddns feature "(.*?)" message$/) do |msg|
	expect(page.current_path).to include('/ddns/success/')
	expect(page).to have_content(msg)
	puts find('div.waiting > span').text
end

Then(/^the user should see ddns feature success message$/) do
	expect(page.current_path).to include('/ddns/success/')
	expect(page).to have_content('DDNS settings have been successfully.')
	puts find('div.zyxel_content h2').text
end

Then(/^the user will redirect to upnp setup page$/) do
	expect(page).to have_content('Synchronizing UPnP settings...')
	puts find('div.waiting > span').text
end

# -------------------------------------------------------------------
# ----------------------------   code   -----------------------------
# -------------------------------------------------------------------

def submit_hostname(hostname)
	fill_in 'hostName', with: hostname
	click_button I18n.t("labels.submit")
end

def create_ddns_session_status(device_id, hostname, status)
	full_domain = hostname + '.' + Settings.environments.ddns
	ddns_session = FactoryGirl.create(:ddns_session, device_id: device_id,
		full_domain: full_domain, status: status)
	ddns_session.save
	ddns_session
	# visit "/ddns/success/#{ddns_session.id}"
end