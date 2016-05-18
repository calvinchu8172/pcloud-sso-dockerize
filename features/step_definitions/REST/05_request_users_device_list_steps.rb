Given(/^a user try to request own device list with (\d+) devices including (\d+) device and (\d+) device from APP$/) do |record_count, own, other|
  domain_id = Domain.find_or_create_by(domain_name: Settings.environments.ddns).id

  array = Array.new

  own.to_i.times do |index|
    device = TestingHelper.create_device_and_xmpp
    device.ddns = Ddns.create(
      device_id: device.id,
      ip_address: "1.2.3.4",
      domain_id: @domain_id,
      hostname: "test"+"#{index+1}"
      )
    FactoryGirl.create(:pairing, user_id: @user.id, device_id: device.id)
    create_fake_invitation_accepted(@user, device, status = 0)
    array << device
  end

  other.to_i.times do |index|
    index = index + own.to_i

    device = TestingHelper.create_device_and_xmpp
    device.ddns = Ddns.create(
      device_id: device.id,
      ip_address: "1.2.3.4",
      domain_id: @domain_id,
      hostname: "test"+"#{index+1}"
      )
    FactoryGirl.create(:pairing, user_id: @user.id, device_id: device.id)
    create_fake_invitation_accepted(@user, device, status = 1)
    array << device
  end

end

Then(/^the JSON response should include$/) do |attributes|
  body_array = JSON.parse(last_response.body)
  attributes = JSON.parse(attributes)

  body_array.each do |key, value|
    attributes.each do |attribute|
      expect(value.key?(attribute)).to be true
    end
  end
end

def create_fake_invitation_accepted(user, device, status)
  cloud_id = user.encoded_id
  share_point = "fake_share_point"
  device_id = device.id

  invitation_key =  cloud_id + share_point + device_id.to_s + Time.now.to_s
  invitation_key = Digest::HMAC.hexdigest(invitation_key, "hash key", Digest::SHA1).to_s

  invitation = Invitation.create(
    key: invitation_key,
    share_point: share_point,
    permission: "1",
    device_id: device_id,
    expire_count: 5,
    )
  invitation.accepted_by user.id
  invitation.accepted_users.first.update_attribute(:status, status)
end