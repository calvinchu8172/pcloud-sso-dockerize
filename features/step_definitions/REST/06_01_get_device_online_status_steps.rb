Given(/^an device exists$/) do
  TestingHelper::create_product_table if Product.count == 0
  @device = FactoryGirl.create(:api_device, product: Product.find(30))
end

When(/^user sends a GET request to \/device\/(\d+)\/online_status with:$/) do |arg1, table|
  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/device/1/online_status"

  if data["certificate_serial"].nil?
    certificate_serial = nil
  elsif data["certificate_serial"].include?("INVALID")
    certificate_serial = "invalid certificate_serial"
  else
    certificate_serial = @certificate.serial
  end

  if data["device_id"].include?("INVALID")
    device_id = "invalid device_id"
  else
    device_id = @device.encoded_id
  end

  if data["signature"].nil?
    signature = nil
  elsif data["signature"].include?("INVALID")
    signature = "invalid signature"
  else
    signature = create_signature(certificate_serial, device_id)
  end

  get path, {
    certificate_serial: certificate_serial,
    device_id: device_id,
    signature: signature
    }

end

Given(/^something wrong when render result$/) do
  allow_any_instance_of(Api::Devices::OnlineStatusController).to receive(:render_success).and_return(false)
end