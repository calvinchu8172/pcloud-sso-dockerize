Given(/^an existing device with pairing signed in client$/) do
  @device = TestingHelper.create_device_and_xmpp
  FactoryGirl.create(:pairing, user_id: @user.id, device_id: @device.id)
end

When(/^client send a POST request to \/resource\/1\/invitation with:$/) do |table|

  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/resource/1/invitation"

  authentication_token = check_authentication_token(data["authentication_token"])
  device_id = data["device_id"].include?("INVALID") ? "" : @device.encoded_id
  share_point = data["share_point"].include?("INVALID") ? "😁" : data["share_point"]

  post path, {
    cloud_id: @user.encoded_id,
    device_id: device_id,
    share_point: share_point,
    permission: data["permission"],
    expire_count: 5,
    authentication_token: authentication_token
    }
end
