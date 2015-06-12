Given(/^an existing invitation record$/) do

  cloud_id = @user.create_authentication_token
  share_point = "fake_share_point"
  device_id = @device.id

  invitation_key =  cloud_id + share_point + device_id.to_s + Time.now.to_s
  invitation_key = Digest::HMAC.hexdigest(invitation_key, "hash key", Digest::SHA1).to_s

  invitation = Invitation.create(
    key: invitation_key,
    share_point: share_point,
    permission: "permission",
    device_id: @device.id,
    expire_count: 5,
    )
  invitation.accepted_by @user.id
  invitation.accepted_users.first.update_attribute(:status, 1)

end

When(/^client send a GET request to "(.*?)" with:$/) do |url_path, table|
  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + url_path

  authentication_token = data["authentication_token"].include?("EXPIRED") ? "" : @user.create_authentication_token

  get path, {
    cloud_id: @user.encoded_id,
    last_updated_at: (5.minute.ago).to_i,
    authentication_token: authentication_token
  }

end

Then(/^the JSON response should include multiple:$/) do |attributes|
  body = JSON.parse(last_response.body).slice(0)
  attributes = JSON.parse(attributes)

  attributes.each do |attribute|
    expect(body.key?(attribute)).to be true
  end
end
