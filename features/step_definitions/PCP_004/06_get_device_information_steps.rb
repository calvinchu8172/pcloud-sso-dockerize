When(/^user click on down arrow button$/) do
  find(:xpath, "//tr/td/div/a[@ng-if='!area.show']").click
  wait_server_response(1)
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
    When user click on down arrow button
  }
end

Then(/^the page should display only one down arrow button$/) do
  expect(page).to have_xpath("//a[@ng-if='area.show']")
  expect(page).to have_xpath("//a[@ng-if='!area.show']")
end

Given(/^the user have a piared device with total capacity: (\d+)MB, used capacity: (\d+)MB$/) do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Then(/^the available capacity should display: (\d+)MB$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^the available capacity percentage should be: (\d+)%$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^the available capacity should display: (\d+)GB$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^the volumn capacity should display: <display>$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^click on volumn div$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^device feedback device info with:$/) do |table|
  data = table.rows_hash
  info_data = {}
  info_data[:volumn_name] = data["volumn_name"]
  info_data[:used_capacity] = data["used_capacity"]
  info_data[:total_capacity] = data["total_capacity"]
  device_for_test(Device.first, info_data)
  wait_server_response(1)
end

Given(/^another device feedback device info with:$/) do |table|
  # data = table.rows_hash
  # info_data = {}
  # info_data[:volumn_name] = data["volumn_name"]
  # info_data[:used_capacity] = data["used_capacity"]
  # info_data[:total_capacity] = data["total_capacity"]
  # device_for_test(Device.last, info_data)
end

def device_for_test(device, info_data = {})

  @redis = Redis.new(:host => '127.0.0.1', :port => '6379', :db => 0 )

  info = %Q({"fan_speed":"759",
     "cpu_temperature_celsius":"39.00",
     "cpu_temperature_fahrenheit":"102.20",
     "cpu_temperature_warning":"false",
     "raid_status":"healthy",
     "volume_list":[
         [ {"volume-name":"#{info_data[:volumn_name]}"},
           {"used-capacity":"#{info_data[:used_capacity]}"},
           {"total-capacity":"#{info_data[:used_capacity]}"},
           {"warning":"false"}
         ],
         [ {"volume-name":"Volume2"},
           {"used-capacity":"400"},
           {"total-capacity":"1832.96"},
           {"warning":"false"}
         ]
       ]}).gsub("\n", "")

  device_info_session_id = @redis.get('device:info:session:index')

  key = 'device:info:'+ device_info_session_id +':session'

  @redis.hset(key, 'status', 'done')

  @redis.hset(key, 'info', info)
  device_info_all = @redis.hgetall(key)
end
