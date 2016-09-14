# Setup the user account
Given(/^a user forgot the password$/) do
  @user = TestingHelper.create_and_confirm
end

# Sign-up a account
Given(/^the user filled correct email$/) do
  @email = @user.email
  filled_in_email(@email)
  TestingHelper.setup_test_email
end

# Finish reset password
When(/^the user finish reset password$/) do
  @email = @user.email
  filled_in_email(@email)
  TestingHelper.setup_test_email
  click_button I18n.t("labels.submit")
  check_resetpwd_email(@email)
end

# Go to forgot password page
Given(/^the user visits Forgot My Password page$/) do
  visit new_user_password_path
end

# Insert value
Given(/^the user filled in an not existed email with "(.*?)"$/) do |email|
  filled_in_email(email)
end

# Click submit button when user didn't fill in email
When(/^the user didn't filled email$/) do
  click_button I18n.t("labels.submit")
end

# Check redirect link for reset password page
Then(/^the user will redirect to reset password page$/) do
  expect(page.current_path).to eq("/users/password/new")
end

# Check redirect link for reset password success page
Then(/^the user will redirect to reset password success page$/) do
  expect(page.current_path).to eq("/hint/reset")
end

# Check error message
Then(/^the user should see an error message from reset password$/) do
  # expect(page).to have_selector('div.input_error input[name="user[email]"]' )
  expect(page).to have_selector('span.help-block')
  puts "Email " + find('span.help-block').text
end

# Check error message from reset password url
Then(/^the user should see an doesn't match error message$/) do
  binding.pry
  # expect(page).to have_selector('div.input_error input[name="user[password_confirmation]"]')
  # puts "Email " + find('div.zyxel_arlert_area>label.error_message').text
  expect(page).to have_selector('span.alert')
  puts "Email " + find('span.alert').text
end

# Check error message with different password
And(/^the user fill in password New:"(.*?)", Confirm:"(.*?)" and submit$/) do |password1, password2|
  fill_in I18n.t("user.labels.new_password"), with: password1
  # fill_in I18n.t("user.labels.new_password_confirmation"), with: password2
  click_button I18n.t("labels.submit")
end

# Check email contents
Then(/^the user should receive an reset password email$/) do
  check_resetpwd_email(@email)
end

# Click reset password link
Then(/^the user click reset password email link/) do
  click_resetpwd_link
end

# Click reset password link(with token url)
def click_resetpwd_link
  confirm_token = @email.body.match(/reset_password_token=[\w\-]*/)
  visit "/users/password/edit?#{confirm_token}"
end

# Check reset password email content.
def check_resetpwd_email(user_email)
  @email = ActionMailer::Base.deliveries.first
  expect(@email.from.first).to eq(ActionMailer::Base.default[:from])
  expect(@email.to.first).to eq(user_email)
  expect(@email.body).to have_content("You have requested to reset your myZyXELcloud password.")
  expect(@email.body).to match(/\/users\/password/)
end

def filled_in_email(email)
  fill_in "user[email]", with: email
end