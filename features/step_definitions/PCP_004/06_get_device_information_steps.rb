When(/^user click on down arrow button$/) do
  device_id = Device.first.encoded_id

  within(:xpath, "//tr[contains(@ng-init, '#{device_id}')]") do
    find("a").click
  end

  wait_server_response
end

Then(/^the page should display device information$/) do
  expect(page).to have_content("RAID status")
  expect(page).to have_content("CPU temp")
  expect(page).to have_content("Available capacity")
end

Then(/^the page should include up arrow button$/) do
  expect(page).to have_xpath("//a[@ng-if='area.show']")
end

When(/^user click on up arrow button$/) do
  find(:xpath, "//a[@ng-if='area.show']").click
  wait_server_response(1)
end

Then(/^the page should not display device information$/) do
  expect(page).to have_no_content("RAID status")
  expect(page).to have_no_xpath("//a[@ng-if='area.show']")
end

Given(/^user have another paired device$/) do
  @another_pairing = TestingHelper.create_pairing(@user.id)
  visit authenticated_root_path
end

When(/^user click on down arrow button and then click on another down arrow button$/) do
  steps %{
    When user click on down arrow button
  }

  another_device_id = Device.last.encoded_id

  within(:xpath, "//tr[contains(@ng-init, '#{another_device_id}')]") do
    find("a").click
  end

  wait_server_response(1)
end

Then(/^the page should display only one down arrow button$/) do
  expect(page).to have_xpath("//a[@ng-if='area.show']")
  expect(page).to have_xpath("//a[@ng-if='!area.show']")
end

Then(/^the available capacity should display: (\d+)$/) do |arg1|
  expect(page).to have_content(arg1)
end

Then(/^the available capacity should display: (\d+)\.(\d+)$/) do |arg1, arg2|
  # page.save_screenshot('screenshot.png')
  expect(page).to have_content(arg1 + "." + arg2)
end

Then(/^the volumn capacity should display: (\d+)\.(\d+)$/) do |arg1, arg2|
  expect(page).to have_content(arg1 + "." + arg2)
end

Then(/^the available capacity percentage should be: (\d+)\.(\d+)%$/) do |arg1, arg2|
  expect(page).to have_content(arg1 + "." + arg2 + "%")
end

Then(/^the volumn capacity should display: (\d+)$/) do |arg1|
  expect(page).to have_content(arg1)
end

When(/^click on volumn div$/) do
  find(:xpath, '//div[@ng-click="changeUnit();"]').click
end

When(/^user click on down arrow button and up arrow button over 5 times$/) do
  5.times do
    steps "When user click on down arrow button"
    wait_server_response(3)
    steps "When user click on up arrow button"
  end
end

Given(/^device feedback device info with:$/) do |table|
  data = table.rows_hash
  info_data = {}
  info_data[:volumn_name] = data["volumn_name"]
  info_data[:used_capacity] = data["used_capacity"]
  info_data[:total_capacity] = data["total_capacity"]
  device_for_test(info_data)
  wait_server_response
end

def device_for_test(info_data = {})

  # @redis = Redis.new(:host => '127.0.0.1', :port => '6379', :db => 0 )
  @redis = Redis.new(:host => Settings.redis.web_host, :port => Settings.redis.port, :db => 0 )

  info = %Q({"fan_speed":"759",
     "cpu_temperature_celsius":"39.00",
     "cpu_temperature_fahrenheit":"102.20",
     "cpu_temperature_warning":"false",
     "raid_status":"healthy",
     "volume_list":[
         [ {"volume-name":"#{info_data[:volumn_name]}"},
           {"used-capacity":"#{info_data[:used_capacity]}"},
           {"total-capacity":"#{info_data[:total_capacity]}"},
           {"warning":"false"}
         ]
       ]}).gsub("\n", "")

  device_info_session_id = @redis.get('device:info:session:index')

  key = 'device:info:'+ device_info_session_id +':session'

  @redis.hset(key, 'status', 'done')

  @redis.hset(key, 'info', info)
  # device_info_all = @redis.hgetall(key)
end
