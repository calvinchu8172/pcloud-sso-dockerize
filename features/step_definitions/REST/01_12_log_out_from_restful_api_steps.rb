When(/^client send a DELETE request to \/user\/(\d+)\/token with:$/) do |arg1, table|
  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/user/1/token"

  cloud_id = data["cloud_id"].include?("INVALID") ? "" : @user.encoded_id
  account_token = data["account_token"].include?("INVALID") ? "" : @user.create_token_set[:account_token]

  delete path, {
    cloud_id: cloud_id,
    account_token: account_token
  }
end