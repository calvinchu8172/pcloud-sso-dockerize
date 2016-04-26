When(/^client send a PUT request to \/user\/1\/email with:$/) do |table|

  ActionMailer::Base.deliveries.clear

  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/user/1/email"

  email = data["email"].include?("SAME") ? @user.email : data["email"]
  cloud_id = data["cloud_id"].include?("INVALID") ? "" : @user.encoded_id
  authentication_token = check_authentication_token(data["authentication_token"])

  put path, {
    cloud_id: cloud_id,
    authentication_token: authentication_token,
    new_email: email
  }
end

Given(/^client has not confirmed$/) do
  @user.update_attributes(confirmed_at: nil)
end
