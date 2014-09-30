Given(/^the user visits DDNS setup page$/) do
	page.set_rack_session(first_pairing: true)
	visit "/ddns/setting/#{@pairing.device_id}"
end

Given(/^the device was first setting DDNS after paired$/) do
	wait_server_response
end
# -------------------------------------------------------------------
# ---------------------------    input   ----------------------------
# -------------------------------------------------------------------
Given(/^the user filled the valid Hostname$/) do
	submit_hostname('valid')
end

Given(/^the user filled the invalid Hostname (.*?)$/) do |value|
	submit_hostname(value)
end

Given(/^the user filled the exist Hostname$/) do
	submit_hostname('zyxel')
end

When(/^the server update DDNS setting failed$/) do
	wait_server_response
	@ddns_session = get_ddns_session(@pairing.device_id)
	set_ddns_session(@ddns_session, "failure")
end

When(/^the server update DDNS setting successfully$/) do
	wait_server_response
	@ddns_session = get_ddns_session(@pairing.device_id)
	set_ddns_session(@ddns_session,"success")
end

# -------------------------------------------------------------------
# ---------------------------   output   ----------------------------
# -------------------------------------------------------------------

Then(/^the user should see error message for Hostname$/) do
	expect(page).to have_selector('div.zyxel_arlert_area > span')
	puts find('div.zyxel_arlert_area > span').text
end

Then(/^the user should see "(.*?)" message on DDNS setup page$/) do |msg|
	expect(page).to have_content(msg)
	puts find('div.waiting > span').text
end

Then(/^the user should see success message on DDNS setup page$/) do
	expect(page).to have_content('DDNS settings have been successfully.')
	puts find('div.zyxel_content h2').text
end

Then(/^the user will redirect to UPnP setup page$/) do
	expect(page.current_path).to include('/upnp')
end

# -------------------------------------------------------------------
# ----------------------------   code   -----------------------------
# -------------------------------------------------------------------

def submit_hostname(hostname)
	fill_in 'hostName', with: hostname
end

def get_ddns_session(device_id)
	ddns_session = DdnsSession.find_by_device_id(device_id)
end

def set_ddns_session(ddns_session, status)
	ddns_session.status = status
	ddns_session.save
	wait_server_response
	ddns_session
end