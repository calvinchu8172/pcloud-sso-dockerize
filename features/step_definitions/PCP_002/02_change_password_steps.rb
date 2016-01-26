# Set a user who visit password change page
Given(/^the user was login and visits change password page$/) do
  # @redis = Redis.new(:host => '127.0.0.1', :port => '6379', :db => 0 )
  # @redis = Redis.new
  @redis = Redis.new(:host => Settings.redis.web_host, :port => Settings.redis.port, :db => 0 )
  @user = TestingHelper.create_and_signin
	visit edit_user_registration_path(type: "password")
end

# Go to forgot password page
Given(/^the user has other 3 logined machines with account tokens and authentication tokens$/) do
  api_user = Api::User.find(@user.id)
  3.times do |i|
    api_user.create_token_set
  end
end

Given(/^the user should have 3 account tokens$/) do
  expect(@redis.keys("user:#{@user.id}:account_token:*").length).to eq(3)
end

Given(/^the user should have 3 authentication tokens$/) do
  expect(@redis.keys("user:#{@user.id}:authentication_token:*").length).to eq(3)
end
# -------------------------------------------------------------------
# ---------------------------    input   ----------------------------
# -------------------------------------------------------------------

When(/^the user filled in current password was incorrect$/) do
  fill_in I18n.t("user.labels.current_password"), with: 'notpassword'
end

When(/^the user filled in current password$/) do
  fill_in I18n.t("user.labels.current_password"), with: @user.password
end

When(/^the user filled the new password$/) do
  fill_in I18n.t("user.labels.password"), with: "newpassword"
  fill_in I18n.t("user.labels.password_confirmation"), with: "newpassword"
end

When(/^the user click submit for change password$/) do
  click_button I18n.t("labels.submit")
end

# -------------------------------------------------------------------
# ---------------------------   output   ----------------------------
# -------------------------------------------------------------------

Then(/^the user will get error message from change password$/) do
	expect(page).to have_selector('.zyxel_arlert_area')
end

Then(/^the user will get success message from change password$/) do
	expect(page).to have_selector('.zyxel_smallok_area')
end

Then(/^the user's account tokens and authentication tokens should all revoked$/) do
  expect(@redis.keys('user:#{@user.id}:*_token:*').length).to eq(0)
end

