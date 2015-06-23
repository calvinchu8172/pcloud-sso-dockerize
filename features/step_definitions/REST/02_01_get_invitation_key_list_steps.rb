Given(/^(\d+) existing invitation record$/) do |record_count|
  record_count.to_i.times { create_fake_invitation(@user, @device) }
end

When(/^client send a GET request to \/resource\/1\/invitation with:$/) do |table|
  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/resource/1/invitation"

  authentication_token = data["authentication_token"].include?("EXPIRED") ? "" : @user.create_authentication_token
  cloud_id = data["cloud_id"].include?("INVALID") ? "" : @user.encoded_id
  last_updated_at = data["last_updated_at"].include?("EXPIRED") ? Time.now.to_i : 5.minute.ago.to_i
  get path, {
    cloud_id: cloud_id,
    last_updated_at: last_updated_at,
    authentication_token: authentication_token
  }

end

Then(/^the JSON response should be empty$/) do
  expect(JSON.parse(last_response.body).count).to eq(0)
end

def create_fake_invitation(user, device)
  cloud_id = user.encoded_id
  share_point = "fake_share_point"
  device_id = device.id

  invitation_key =  cloud_id + share_point + device_id.to_s + Time.now.to_s
  invitation_key = Digest::HMAC.hexdigest(invitation_key, "hash key", Digest::SHA1).to_s

  invitation = Invitation.create(
    key: invitation_key,
    share_point: share_point,
    permission: "1",
    device_id: @device.id,
    expire_count: 5,
    )
  invitation.accepted_by @user.id
  invitation.accepted_users.first.update_attribute(:status, 1)
end
