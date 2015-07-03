Given(/^a user sign in from APP$/) do
  @user = TestingHelper.create_and_confirm(FactoryGirl.create(:api_user))
  # @user2 = TestingHelper.create_and_confirm(FactoryGirl.create(:api_user))
  # @user3 = TestingHelper.create_and_confirm(FactoryGirl.create(:api_user))

end

Given(/^a user try to request own device list from APP$/) do
  @domain_id = Domain.create(domain_name: Settings.environments.ddns).id

  @device1 = TestingHelper.create_device_and_xmpp
  @device1.ddns = Ddns.create(
    device_id: @device1.id,
    ip_address: "1.2.3.4",
    domain_id: @domain_id,
    hostname: "test"
    )
  FactoryGirl.create(:pairing, user_id: @user.id, device_id: @device1.id)
  create_fake_invitation_accepted(@user, @device1, 0)
  # binding.pry
  @device2 = TestingHelper.create_device_and_xmpp
  @device2.ddns = Ddns.create(
    device_id: @device2.id,
    ip_address: "1.2.3.4",
    domain_id: @domain_id,
    hostname: "test2"
    )
  FactoryGirl.create(:pairing, user_id: @user.id, device_id: @device2.id)
  create_fake_invitation_accepted(@user, @device2, 1)

  @device3 = TestingHelper.create_device_and_xmpp
  @device3.ddns = Ddns.create(
    device_id: @device3.id,
    ip_address: "1.2.3.4",
    domain_id: @domain_id,
    hostname: "test3"
    )
  FactoryGirl.create(:pairing, user_id: @user.id, device_id: @device3.id)
  create_fake_invitation_accepted(@user, @device3, 1)

end

When(/^APP sent a GET request to "(.*?)" with:$/) do |url_path, table|


  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + url_path

  authentication_token = data["authentication_token"].include?("EXPIRED") ? "" : @user.create_authentication_token
  cloud_id = data["cloud_id"].include?("INVALID") ? "" : @user.encoded_id
  # binding.pry
  get path, {
    cloud_id: cloud_id,
    authentication_token: authentication_token
  }
end

# Then(/^the HTTP response status should be "(.*?)"$/) do |status_code|
#   expect(last_response.status).to eq(status_code.to_i)
# end

Then(/^the JSON response should include$/) do |attributes|
  body_array = JSON.parse(last_response.body)
  attributes = JSON.parse(attributes)
  binding.pry

  body_array.each do |key, value|
    attributes.each do |attribute|
      expect(value.key?(attribute)).to be true
    end
  end
end

# Then(/^the responsed JSON should include error code: "(.*?)"$/) do |error_code|
#   body = JSON.parse(last_response.body)
#   expect(body["error_code"]).to eq(error_code)
# end

# Then(/^the responsed JSON should include description: "(.*?)"$/) do |description|
#   body = JSON.parse(last_response.body)
#   expect(body["description"]).to eq(description)
# end

def create_fake_invitation_accepted(user, device, status)
  cloud_id = user.encoded_id
  share_point = "fake_share_point"
  device_id = device.id
  status == 1? 1 : 0

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

def create_fake_invitation_not_accepted(user, device)
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
  invitation.accepted_users.first.update_attribute(:status, 0)
end