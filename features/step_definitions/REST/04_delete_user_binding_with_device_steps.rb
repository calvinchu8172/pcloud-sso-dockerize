
When(/^client send a DELETE request to \/resource\/1\/permission with:$/) do |table|
  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/resource/1/permission"

  device_account = data["device_account"].include?("INVALID") ? "" : @device.session['xmpp_account']
  cloud_id = data["cloud_id"].include?("INVALID") ? "" : @user.encoded_id
  certificate_serial = data["certificate_serial"].include?("INVALID") ? "" : @certificate.serial

  signature = create_signature(certificate_serial, device_account, cloud_id)
  signature = "" if data["signature"].include?("INVALID")

  delete path, {
    device_account: device_account,
    cloud_id: cloud_id,
    certificate_serial: certificate_serial,
    signature: signature
  }

end

Then(/^permission record count should be (\d+)$/) do |count|
  expect(Api::Resource::Permission.count).to eq(count.to_i)
end
