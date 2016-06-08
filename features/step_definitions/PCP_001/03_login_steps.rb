# Setup user account
Given(/^a user want to login$/) do
  @user = FactoryGirl.create(:user)
  ActionMailer::Base.deliveries.clear
end

# Go to Login page
Given(/^the user visits login page$/) do
  visit unauthenticated_root_path
end

Given(/^the user change language (.*?)$/) do |locale|
  click_link locale
end

# -------------------------------------------------------------------
# ----------------- Filled in Login information ---------------------
# -------------------------------------------------------------------

Given(/^the user try to login with an unconfirmed account$/) do
  filled_in_login_info(@user.password)
end

Given(/^the user filled the invalid information$/) do
  filled_in_login_info("23456789")
end

Given(/^the user filled the correct information$/) do
  filled_in_login_info(@user.password)
end

Given(/^the account was confirmed$/) do
  @user.confirm
  @user.save
end

Given(/^the user has registered more than (\d+) days$/) do |days|
  @user.created_at = (days.to_i + 1).days.ago
  @user.save
end

Given(/^the user click unverified link$/) do
  ActionMailer::Base.deliveries.clear
  click_link "Unverified"
end

Then(/^new confirmation email should be delivered$/) do
  expect(ActionMailer::Base.deliveries.count).to eq(1)
  expect(ActionMailer::Base.deliveries.first.to).to include("new@example.com")
end

Given(/^an existing user's email is "(.*?)"$/) do |email|
  FactoryGirl.create(:user, email: email)
end

When(/^fill changing email "(.*?)"$/) do |email|
  fill_in "user[email]", with: email
end

When(/^user click confirmation email link$/) do
  email = ActionMailer::Base.deliveries.last
  confirm_token = email.body.match(/confirmation_token=[\w\-]*/)
  visit "/users/confirmation?#{confirm_token}"
end

Then(/^the page should redirect to hint sign up page$/) do
  expect(page.current_path).to include(hint_signup_path)
end

Then(/^the page should redirect to edit email confirmation page$/) do
  expect(page.current_path).to eq(users_confirmation_edit_path)
end

Then(/^the page should redirect to hint confirmation sent page$/) do
  expect(page.current_path).to eq(hint_confirm_sent_path)
end

Then(/^the page should redirect to sign in page$/) do
  expect(page).to have_content("Sign in")
end

Then(/^the user email account should be changed to "(.*?)"$/) do |email|
  expect(User.first.email).to eq(email)
end

Given(/^user doesn't confirm email over (\d+) days$/) do |arg1|
  @user.created_at = @user.created_at - 4.days
  @user.save
end

Then(/^user can only visit resend email of confirmation page$/) do
  visit root_path
  expect(page.current_path).to eq("/users/confirmation/new")
end


# -------------------------------------------------------------------
# -------------------------- Expect result --------------------------
# -------------------------------------------------------------------
Then(/^the page should redirect to resend email of confirmation page$/) do
  ActionMailer::Base.deliveries.clear
  expect(page.current_path).to eq(new_user_confirmation_path)
end

Then(/^the user should see the warning message$/) do
  expect(page).to have_content(I18n.t("devise.failure.unconfirmed"))
end

Then(/^the user should see the error message$/) do
  expect(page).to have_content(I18n.t("devise.failure.invalid"))
end

Then(/^the user should see the information when login successfully$/) do
  expect(page).to have_content(I18n.t("devise.sessions.signed_in"))
end

Then(/^the user should see Sign In word in correct language$/) do
  puts find('div.signupForm > header').text
end

Then(/^the user language information will be changed after user login to system$/) do
  steps %{
    Given the user filled the correct information
    And the account was confirmed
  }
  find('.zyxel_btn_login_submit').click
  puts User.find(@user.id).language
end

Then(/^confirmation email should be delivered$/) do
  @email = ActionMailer::Base.deliveries.first
  expect(ActionMailer::Base.deliveries.count).to eq(1)
  expect(@email.subject).to include("Account Confirmation")
end

def filled_in_login_info(password)
  fill_in "user[email]", with: @user.email
  fill_in "user[password]", with: password
end