When(/^client send a GET request to "(.*?)" with:$/) do |url_path, table|

  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + url_path
  cloud_id = data["cloud_id"].include?("INVALID") ? "" : @user.encoded_id
  authentication_token = check_authentication_token(data["authentication_token"])

  get path, {
    cloud_id: cloud_id,
    authentication_token: authentication_token
  }
end