When(/^client send a PUT request to \/user\/(\d+)\/token with:$/) do |arg1, table|
  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/user/1/token"

  cloud_id = data["cloud_id"].include?("INVALID") ? "" : @user.encoded_id

  array = @user.create_token_set
  @account_token = array[:account_token]
  @authentication_token = array[:authentication_token]

  account_token = data["account_token"].include?("INVALID") ? "" : @account_token

  put path, {
    cloud_id: cloud_id,
    account_token: account_token
  }
end


Then(/^the JSON response should not be the same with:$/) do |response|

  a = JSON.parse(response)
  a["authentication_token"] = @authentication_token
  b = JSON.parse(last_response.body)

  expect(b["authentication_token"]).not_to eq(a["authentication_token"])

end