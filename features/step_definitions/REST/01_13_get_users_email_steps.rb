Given(/^a device has some valid cloud_id and some invalid cloud_id with:$/) do
  @total = rand(10..20)
  array = Array.new(@total)

  array.map! do |user|
    if rand(2) == 1
      user = TestingHelper.create_and_confirm(FactoryGirl.create(:api_user))
      user.encoded_id
    else
      user = "INVALID ENCODE USER ID"
    end
  end

  @invalid = array.select { |d| d.include?("INVALID")}.size
  @valid = @total - @invalid

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

