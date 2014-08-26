# Visit manually add with a user, register a device
Given(/^a user visit manually add page$/) do
  @user = TestingHelper.create_and_signin
  @device_session = TestingHelper.create_device_session
  visit '/discoverer/add/'
end

# -------------------------------------------------------------------
# ---------------------------    input   ----------------------------
# -------------------------------------------------------------------

When(/^the user filled the invalid mac address$/) do
  fill_in I18n.t("labels.mac_address"), with: '%%:%%:%%:%%:%%:%%'
end

When(/^the user filled the exists device information$/) do
  fill_in I18n.t("labels.mac_address"), with: @device_session.device.mac_address
  fill_in I18n.t("labels.serial_number"), with: @device_session.device.serial_number
end

When(/^the user filled the not exists device information$/) do
  fill_in I18n.t("labels.mac_address"), with: '11:11:11:11:11:11'
  fill_in I18n.t("labels.serial_number"), with: 'not_invalid'
end

# -------------------------------------------------------------------
# ---------------------------   output   ----------------------------
# -------------------------------------------------------------------


Then(/^the user should see mac address error message$/) do 
  expect(page).to have_selector('div.zyxel_arlert_area')
  puts "Mac Address " + find('div.zyxel_arlert_area > span').text
end

Then(/^the user should see manually add feature error message$/) do
  expect(page).to have_selector('div.serial_number_alert')
  puts "Device " + find('div.serial_number_alert > span').text
end

Then(/^the user will redirect to pairing check page$/) do
	expect(page.current_path).to include('/discoverer/check')
  puts page.current_path
end
