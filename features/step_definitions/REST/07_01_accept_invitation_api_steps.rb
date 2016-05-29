Given(/^the device paired with the user$/) do
  @pairing = FactoryGirl.create(:pairing, user_id: @user.id, device_id: @device.id)
end

Given(/^user has gernerate an invitation key$/) do
  invitation_key =  @cloud_id + "share_folder" + @device.id.to_s + Time.now.to_s
  @invitation_key = Digest::HMAC.hexdigest(invitation_key, "hash key", Digest::SHA1).to_s
  @invitation = FactoryGirl.create(:invitation, key: @invitation_key, device_id: @device.id)
end

Given(/^an invitee exists$/) do
  @invitee = FactoryGirl.create(:api_user)
  @invitee.skip_confirmation!
  @invitee.save
  @invitee_cloud_id = @invitee.encoded_id
end

When(/^user sends a POST request to \/resource\/(\d+)\/permission with:$/) do |arg1, table|
  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/resource/1/permission"

  if data["certificate_serial"].nil?
    certificate_serial = nil
  elsif data["certificate_serial"].include?("INVALID")
    certificate_serial = "invalid certificate_serial"
  else
    certificate_serial = @certificate.serial
  end

  if data["cloud_id"].include?("INVALID")
    @invitee_cloud_id = "invalid cloud_id"
  elsif data["cloud_id"].include?("VALID USER")
    @invitee_cloud_id = @cloud_id
  else
    @invitee_cloud_id
  end

  if data["invitation_key"].include?("INVALID")
    @invitation_key = "invalid invitation_key"
  else
    @invitation_key
  end

  if data["signature"].nil?
    signature = nil
  elsif data["signature"].include?("INVALID")
    signature = "invalid signature"
  else
    signature = create_signature(certificate_serial, @invitee_cloud_id, @invitation_key)
  end

  post path, {
    cloud_id: @invitee_cloud_id,
    invitation_key: @invitation_key,
    certificate_serial: certificate_serial,
    signature: signature
    }

end

Then(/^the JSON response should be:$/) do |table|
  data = table.rows_hash
  body_hash = JSON.parse(last_response.body)
  # binding.pry

  data.each do |key, value|
    expect(body_hash.key?(key)).to be true
    expect(body_hash.value?(value)).to be true
  end
end

When(/^the invitation key expire count is (\d+)$/) do |number|
  @invitation.expire_count = 0
  @invitation.save
end

When(/^the device is unpaired$/) do
  @pairing.destroy
end

When(/^the invitaion is accepted before$/) do
  @accepted_user = FactoryGirl.create(:accepted_user, invitation_id: @invitation.id, user_id: @invitee.id, status: 1)
end

When(/^something wrong when set session or other error$/) do
  allow_any_instance_of(Invitation).to receive(:accepted_by).and_raise(Exception)
  allow_any_instance_of(AcceptedUser).to receive(:session).and_raise(Exception)
  # allow_any_instance_of(AwsService).to receive(:send_message_to_queue).and_raise(Exception)
end



