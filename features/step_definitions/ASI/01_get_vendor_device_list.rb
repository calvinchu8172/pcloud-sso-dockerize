Given(/^an user exists$/) do
   @user = FactoryGirl.create(:api_user)
   @user.skip_confirmation!
   # @user.id = 1
   @user.save
   @cloud_id = @user.encoded_id
   # puts @user.id
   # puts @cloud_id
end

Given(/^there is a NAS paired with user$/) do
  TestingHelper::create_product_table if Product.count == 0
  @device = FactoryGirl.create(:api_device, product: Product.find(30))
  @pairing = FactoryGirl.create(:pairing, user: @user, device: @device)
end

Given(/^there is no vendor device in database$/) do
  expect(VendorDevice.find_by(user_id: @user.id).nil?).to eq(true)
end

Given(/^there is an existed vendor device in database$/) do
  @vendor = FactoryGirl.create(:vendor, id: 1)
  @vendor_product = FactoryGirl.create(:vendor_product, id: 1, vendor_id: 1)
  @vendor_device = FactoryGirl.create(:vendor_device, id: 1, vendor_id: 1, vendor_product_id: 1, user_id: @user.id)
end

Given(/^the vendor device has updated more then (\d+) minutes$/) do |arg1|
  @vendor_device.update(updated_at: Time.now - 12*60)
end

Given(/^the NAS is not paired with user$/) do
  @pairing.destroy
end

Given(/^there is no this NAS corresponding to the mac_address and serial_number$/) do
  @pairing.destroy
  @device.destroy
end

Given(/^the ASI server return valid result$/) do
  data = "{\"resultCode\":\"000.000\",\"data\":[{\"ircutSupport\":\"1\",\"deviceLicenseKey\":\"IVSIPCSP01-V101V52TEY7KC0IZ\",\"productClass\":\"IPCAM\",\"network\":\"ETHERNET\",\"ip\":\"192.168.12.79\",\"recTagSupport\":\"0\",\"isOnline\":\"1\",\"devicePurchaseDate\":\"\",\"microphoneSupport\":\"1\",\"modelName\":\"C11W\",\"nickName\":\"B01F81700417\",\"externalIp\":\"192.168.12.1\",\"firmwareVersion\":\"C11W-2.0.8\",\"speakerSupport\":\"1\",\"ptzSupport\":\"-1\",\"deviceId\":\"B01F81700417\",\"deviceLicenseActivatedDate\":\"2016-04-27 14:29:39.0\"}],\"resultMessage\":\"Success.\"}"
  # allow_any_instance_of(Api::Resource::VendorDevicesController).to receive(:get_devise_list_from_vendor).with("zyxoperator").and_return(data)
  puts @cloud_id
  allow_any_instance_of(Api::Resource::VendorDevicesController).to receive(:get_devise_list_from_vendor).with(@cloud_id).and_return(data)

end

Given(/^the ASI server return invalid result$/) do
  data ="{\"resultCode\":\"400.403\",\"resultMessage\":\"User not found.\"}"
  allow_any_instance_of(Api::Resource::VendorDevicesController).to receive(:get_devise_list_from_vendor).with("invalid cloud id").and_return(data)
end

When(/^NAS send a GET request to \/resource\/(\d+)\/vendor_devices with:$/) do |arg, table|
  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/resource/1/vendor_devices"

  if data["certificate_serial"].nil?
    certificate_serial = nil
  elsif data["certificate_serial"].include?("INVALID")
    certificate_serial = "invalid certificate_serial"
  else
    certificate_serial = @certificate.serial
  end

  if data["cloud_id"].include?("INVALID")
    cloud_id = "invalid cloud_id"
  else
    cloud_id = @cloud_id
  end

  if data["mac_address"].include?("INVALID")
    mac_address = "invalid mac_address"
  else
    mac_address = @device.mac_address
  end

  if data["serial_number"].include?("INVALID")
    serial_number = "invalid serial_number"
  else
    serial_number = @device.serial_number
  end

  if data["signature"].nil?
    signature = nil
  elsif data["signature"].include?("INVALID")
    signature = "invalid signature"
  else
    signature = create_signature(certificate_serial, cloud_id, mac_address, serial_number)
    # puts signature
  end

  get path, {
    certificate_serial: certificate_serial,
    cloud_id: cloud_id,
    mac_address: mac_address,
    serial_number: serial_number,
    signature: signature
    }

end

Then(/^there is vendor device data in database$/) do
  expect(VendorDevice.find_by(user_id: @user.id).nil?).to eq(false)
end

Then(/^the updated time will keep the same$/) do
  expect(VendorDevice.find_by(user_id: @user.id).updated_at.min).to eq(@vendor_device.updated_at.min)
end

Then(/^the updated time will be updated$/) do
  expect(VendorDevice.find_by(user_id: @user.id).updated_at).not_to eq(@vendor_device.updated_at)
end

Then(/^the JSON response should include the error:$/) do |table|
  data = table.rows_hash
  body_hash = JSON.parse(last_response.body)

  data.each do |key, value|
    expect(body_hash.key?(key)).to be true
    expect(body_hash.value?(value)).to be true
  end
end

