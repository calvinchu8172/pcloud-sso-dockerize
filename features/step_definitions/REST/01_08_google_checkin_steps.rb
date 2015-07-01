When(/^client send a GET request to \/user\/1\/checkin\/google with:$/) do |table|
  path = '//' + Settings.environments.api_domain + "/user/1/checkin/google"

  data = table.rows_hash
  user_id = data["user_id"].include?("INVALID") ? "" : @uuid
  access_token = data["access_token"].include?("INVALID") ? "" : @access_token

  if user_id.blank? || access_token.blank?
    Api::User::OauthController.any_instance.stub(get_oauth_data: nil)
  else
    Api::User::OauthController.any_instance.stub(get_oauth_data: @oauth_data)
  end

  get path, {
    user_id: user_id,
    access_token: access_token
  }
end
