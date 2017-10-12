Given(/^A signed in user$/) do
  @user = TestingHelper.create_and_signin
end

Given(/^client app has logout redirect uri$/) do
  @oauth_client_app.update(logout_redirect_uri: 'https://www.example.com/')
end

Given(/^user visits logout url$/) do
  visit "/oauth/logout?client_id=#{@client_id}&logout_redirect_uri=#{@oauth_client_app.logout_redirect_uri}"
end

Then(/^user will be redirect to logout redirect uri$/) do
  expect(current_url).to eq('https://www.example.com/')
end

Then(/^user will be redirect to login page$/) do
  expect(current_path).to eq('/users/sign_in')
end

Given(/^user visits logout url without client_id$/) do
  visit "/oauth/logout?logout_redirect_uri=#{@oauth_client_app.logout_redirect_uri}"
end

Given(/^user visits logout url without logout_redirect_uri$/) do
  visit "/oauth/logout?client_id=#{@client_id}"
end