# Visit manually add with a user, register a device
Given(/^a user visits manually add page$/) do
  @user = TestingHelper.create_and_signin
  @device = TestingHelper.create_device
  @old_model_device = TestingHelper.create_device(28)
  visit '/discoverer/add'
end

# -------------------------------------------------------------------
# ---------------------------    input   ----------------------------
# -------------------------------------------------------------------

Given(/^the user filled the invalid "(.*?)" (.*?)$/) do |item, value|
  fill_in I18n.t("labels.mac_address"), with: value
end

Given(/^the user filled the exists device information$/) do
  fill_in I18n.t("labels.mac_address"), with: @device.mac_address
  fill_in I18n.t("labels.serial_number"), with: @device.serial_number
end

Given(/^the user filled the not exists device information$/) do
  fill_in I18n.t("labels.mac_address"), with: '11:11:11:11:11:11'
  fill_in I18n.t("labels.serial_number"), with: 'not_invalid'
end

Given(/^the user filled the device information of NSA325 or NSA325 v2$/) do
  fill_in I18n.t("labels.mac_address"), with: @old_model_device.mac_address
  fill_in I18n.t("labels.serial_number"), with: @old_model_device.serial_number
end

# -------------------------------------------------------------------
# ---------------------------   output   ----------------------------
# -------------------------------------------------------------------


Then(/^the user should see error message for mac address$/) do
  expect(page).to have_selector('div.zyxel_arlert_area')
  puts find('div.zyxel_arlert_area > span').text
end

Then(/^the user should see error message on manually add page$/) do
  expect(page).to have_selector('div.serial_number_alert')
  puts "Device " + find('div.serial_number_alert > span').text
end

Then(/^the user will redirect to pairing check page$/) do
	expect(page.current_path).to eq("/discoverer/check/#{@device.escaped_encrypted_id}.format")
end

Then(/^the user will redirect to pairing check page of NSA325 or NSA325 v2$/) do
  expect(page.current_path).to eq("/discoverer/check/#{@old_model_device.escaped_encrypted_id}.format")
end

Then(/^redirect to Search Devices page$/) do
  expect(page.current_path).to eq('/discoverer/index')
end