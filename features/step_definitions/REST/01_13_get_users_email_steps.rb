Given(/^a device has (\d+) valid cloud_id and (\d+) invalid cloud_id with:$/) do |arg1, arg2, table|
  data = table.rows_hash

  user1 = TestingHelper.create_and_confirm(FactoryGirl.create(:api_user))
  user2 = TestingHelper.create_and_confirm(FactoryGirl.create(:api_user))
  user3 = TestingHelper.create_and_confirm(FactoryGirl.create(:api_user))

  cloud_id1 = user1.encoded_id
  cloud_id2 = user2.encoded_id
  cloud_id3 = user3.encoded_id
  cloud_id4 = data["cloud_id4"]
  cloud_id5 = data["cloud_id5"]

  @cloud_ids = cloud_id1+","+cloud_id2+","+cloud_id3+","+cloud_id4+","+cloud_id5

end

When(/^device request GET to \/user\/(\d+)\/email with:$/) do |arg1, table|
  data = table.rows_hash
  cloud_ids = data["cloud_ids"].include?("INVALID") ? "" : @cloud_ids

  certificate_serial = @certificate.serial
  signature = create_signature(certificate_serial, cloud_ids)
  signature = "" if data["signature"].include?("INVALID")

  path = '//' + Settings.environments.api_domain + "/user/1/email"

  get path, {
    cloud_ids: cloud_ids,
    certificate_serial: certificate_serial,
    signature: signature
  }
end

Then(/^the JSON response at "(.*?)" size should be (\d+)$/) do |description, number|
  body_array = JSON.parse(last_response.body)
  expect(body_array[description].size).to eq(number.to_i)
end
