Given(/^a device has (\d+) emails including (\d+) cloud_id and some (\d+) cloud_id with:$/) do |record_count, valid, invalid|

  array = Array.new

  @valid = valid.to_i
  @invalid = invalid.to_i
  @valid.times do
    user = TestingHelper.create_and_confirm(FactoryGirl.create(:api_user))
    array << user.encoded_id
  end

  @invalid.times do
    user = "INVALID ENCODE USER ID"
    array << user
  end

  @cloud_ids = (array).join(",")

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

Then(/^the JSON response at "(.*?)" size should be equal to valid cloud_id number$/) do |arg1|
  body_array = JSON.parse(last_response.body)
  expect(body_array["emails"].size).to eq(@valid)
end

Then(/^the JSON response at "(.*?)" size should be equal to invalid cloud_id number$/) do |arg1|
  body_array = JSON.parse(last_response.body)
  expect(body_array["ids_not_found"].size).to eq(@invalid)
end

