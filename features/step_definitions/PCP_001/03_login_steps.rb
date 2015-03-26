# Setup user account
Given(/^a user want to login$/) do
  @user = FactoryGirl.create(:user)
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
  @user.confirmed_at = Time.now.utc
  @user.confirmation_token = Devise.friendly_token
  @user.confirmation_sent_at = Time.now.utc
  @user.save
end

# -------------------------------------------------------------------
# -------------------------- Expect result --------------------------
# -------------------------------------------------------------------
Then(/^the page should redirect to resend email of confirmation page$/) do
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
  puts User.find(@user).language
end

def filled_in_login_info(password)
  fill_in "user[email]", with: @user.email
  fill_in "user[password]", with: password
end