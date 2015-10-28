When(/^client send a POST request to \/user\/1\/password with:$/) do |table|

  ActionMailer::Base.deliveries.clear

  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/user/1/password"

  email = data["email"]
  post path, email: email

end