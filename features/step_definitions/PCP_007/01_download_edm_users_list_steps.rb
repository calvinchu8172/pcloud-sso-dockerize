Given(/^a user visits download edm users list page without signing in$/) do
  visit "/edm_users"
end

Then(/^user is redirected to sign in page$/) do
  expect(current_path).to eq("/users/sign_in")
end

Given(/^a user signed in$/) do
  @user = TestingHelper.create_and_signin
  @redis = Redis.new(:host => Settings.redis.web_host, :port => Settings.redis.port, :db => 0 )
  @redis.flushdb
  @key = "admin:#{@user.id}:session"
end

Given(/^user visits download edm users list page without admin authority$/) do
  visit "/edm_users"
end

Then(/^user is redirected to root page$/) do
  expect(current_path).to eq("/discoverer/index")
end

Given(/^the session name key is wrong$/) do
  @redis.hset(@key, 'name', 'invalid_email')
end

Given(/^the session name key is right$/) do
  @redis.hset(@key, 'name', @user.email)
end

Given(/^the session auth key doesn't have "(.*?)"$/) do |arg1|
  @redis.hset(@key, 'auth', ["wrong_edm_users"].to_json)
end

Given(/^user visits download edm users list page with admin authority$/) do
  @redis.hset(@key, 'auth', ["download_edm_users"].to_json)
  visit "/edm_users"
end

Then(/^user visits the edm users list page$/) do
  expect(current_path).to eq("/edm_users")
end

Then(/^we make the csv file name as "(.*?)"$/) do |filename|
  allow_any_instance_of(Users::EdmUsersController).to receive(:filename).and_return(filename)
end

Then(/^the user sees the download csv file as "(.*?)"$/) do |filename|
  expect(page.response_headers['Content-Disposition']).to include("filename=\"#{filename}\"")
end

Then(/^the user sees the csv header include:$/) do |attributes|
  attributes = JSON.parse(attributes)
  headers = CSV.parse(page.body)[0]
  expect(attributes).to eq(headers)
end

Then(/^the csv content should have user information with sign_on_by "(.*?)"$/) do |sign_on_by|
  content = CSV.parse(page.body)[1]
  expect(content).to include(@user.id.to_s, @user.email, @user.edm_accept.to_s, @user.language, @user.country, sign_on_by)
end

Given(/^user also binded the account with Facebook and Google$/) do
  FactoryGirl.create(:identity, user_id: @user.id, provider: 'facebook', uid: '1234567890')
  FactoryGirl.create(:identity, user_id: @user.id, provider: 'google_oauth2', uid: '1234567891')
end

Given(/^user also binded the account with Facebook$/) do
  FactoryGirl.create(:identity, user_id: @user.id, provider: 'facebook', uid: '1234567890')
end

Given(/^user also binded the account with Google$/) do
  FactoryGirl.create(:identity, user_id: @user.id, provider: 'google_oauth2', uid: '1234567891')
end

