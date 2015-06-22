When(/^client send a GET request to \/user\/1\/token with:$/) do |table|

  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/user/1/token"

  cloud_id = data["cloud_id"].include?("INVALID") ? "" : @user.encoded_id
  authentication_token = data["authentication_token"].include?("INVALID") ? "" : @user.create_authentication_token
  get path, {
    cloud_id: cloud_id,
    authentication_token: authentication_token
  }
end