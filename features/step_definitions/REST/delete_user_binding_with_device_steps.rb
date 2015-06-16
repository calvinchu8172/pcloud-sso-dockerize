Given(/^a existing device XMPP account$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^client send a DELETE request to "(.*?)" with:$/) do |url_path, table|
  data = table.rows_hash
  path = '//' + Settings.environment.api_domain + url_path

  device_account = data["device_account"].include?("INVALID") ? "" : device_account
  cloud_id = data["cloud_id"].include?("INVALID") ? "" : @user.encoded_id
  certificate_serial = data["certificate_serial"].include("INVALID") ? "" : certificate_serial
  signature = data["signature"].include?("INVALID") ? "" : signature

  delete path, {
    device_id: device_id,
    cloud_id: cloud_id,
    certificate_serial: certificate_serial,
    signature: signature
  }

end

Then(/^the JSON response should be$/) do |response|
  expect(JSON.parse(last_response.body)).to eq(response)
end