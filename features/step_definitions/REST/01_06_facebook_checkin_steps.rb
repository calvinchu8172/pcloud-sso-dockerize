Given(/^an existing client binding with Facebook$/) do
  pending #
end

When(/^client send a GET request to \/user\/1\/checkin\/facebook$/) do

  path = '//' + Settings.environments.api_domain + "/user/1/checkin/facebook"

  user_id = "user_id"
  access_token = "access_token"

  get path, user_id: user_id, access_token: access_token

end