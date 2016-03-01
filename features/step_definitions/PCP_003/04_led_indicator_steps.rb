Given(/^a user visited search devices page$/) do
  # @redis = Redis.new
  @redis = Redis.new(:host => Settings.redis.web_host, :port => Settings.redis.port, :db => 0 )
  @redis.flushdb
  @user = TestingHelper.create_and_signin
end

Given(/^the device connected$/) do
  @device = TestingHelper.create_device
  @device.module_list << 'indicator'
  @redis.HSET "s3:#{@device.session['xmpp_account']}:#{Settings.xmpp.server}:#{Settings.xmpp.device_resource_id}".downcase, "1", "1"
  visit '/discoverer/index'
end

Given(/^the user saw the device in device list$/) do
  expect(page).to have_content('MAC Address')
  expect(page).to have_content(@device.mac_address.scan(/.{2}/).join(":"))
  expect(page).to have_selector('table.devices_list .device, a[href*="/discoverer/check"]')
end

When(/^the connected device in the list is not paired$/) do
  expect(@device.paired?).to be(false)
end

Then(/^the user should see the enabled "(.*?)" button of the device$/) do |arg1|
  # expect(page).to have_content I18n.t('labels.pairing')
  expect(page).to have_content I18n.t('labels.find_nas')
end

When(/^the user click the "(.*?)" button of the device$/) do |arg1|
  click_link I18n.t("labels.find_nas")
end

Then(/^the user should see the "(.*?)" button of the device disabled for (\d+) seconds$/) do |arg1, arg2|
  expect(page).to have_selector('.zyxel_btn_disabled')
  expect(page).not_to have_link( I18n.t('labels.find_nas'), href: "#" )
end

When(/^the "(.*?)" button has already disabled (\d+) seconds and NAS accepted pairing$/) do |button, second|
  sleep 30
end

Then(/^the user should see the "(.*?)" button enable again$/) do |arg1|
  expect(page).to have_link( I18n.t('labels.find_nas'), href: "#" )
end

When(/^the user clicked "(.*?)" link to start pairing$/) do |arg1|
  expect(page).to have_link( I18n.t('labels.pairing'), href: "/discoverer/check/#{@device.encoded_id}")
  click_link I18n.t('labels.pairing')
end

When(/^the user has completed the pairing process$/) do
  @pairing = FactoryGirl.create(:pairing, user_id: @user.id, device_id: @device.id)
  visit '/discoverer/index'
end

Then(/^the user should not see the "(.*?)" button of the paired device$/) do |link|
  expect(page).to have_content I18n.t('labels.paired')
  expect(page).not_to have_content I18n.t('labels.find_nas')
end
