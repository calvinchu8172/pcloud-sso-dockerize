# Setup the user account
Given(/^a user forgot the password$/) do
  @user = FactoryGirl.create(:user)
  @user.confirm!
  @user.save
end

# Sign-up a account
Given(/^the user filled correct email with "(.*?)"$/) do |email|
  @email = email
  filled_in_email(@email)
  setup_test_email
end

# Finish reset password 
When(/^the user finish reset password with "(.*?)"$/) do |email|
  @email = email
  filled_in_email(@email)
  setup_test_email
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

# Click submit button
When(/^the user click "(.*?)" button$/) do |button|
  click_button button
end

# Click link
When(/^the user click "(.*?)" link$/) do |link|
  click_link link
end


# Check redirect link
Then(/^i will redirect to "(.*?)"$/) do |link|
  expect(page.current_path).to eq(link)
end

# Check error message
Then(/^the user should see an error message from reset password$/) do
  expect(page).to have_selector('div.input_error input[name="user[email]"]' )
  puts "Email " + find('div.zyxel_arlert_area>label.error_message').text
end

# Check error message from reset password url
Then(/^the user should see an doesn't match error message$/) do
  expect(page).to have_selector('div.input_error input[name="user[password_confirmation]"]')
  puts "Email " + find('div.zyxel_arlert_area>label.error_message').text
end

# Check error message with different password
Then(/^the user fill in password New:"(.*?)", Confirm:"(.*?)" and submit$/) do |password1, password2|
  @user.confirm!
  fill_in I18n.t("user.labels.new_password"), with: password1
  fill_in I18n.t("user.labels.new_password_confirmation"), with: password2
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

# Send test email for confirmation account
def setup_test_email
  # make your delivery state to 'test' mode
  ActionMailer::Base.delivery_method = :test
  # make sure that actionMailer perform an email delivery
  ActionMailer::Base.perform_deliveries = true
  # clear all the email deliveries, so we can easily checking the new ones
  ActionMailer::Base.deliveries.clear
end

# Click reset password link(with token url)
def click_resetpwd_link
  @email = ActionMailer::Base.deliveries.first
  confirm_token = @email.body.match(/reset_password_token=[\w\-]*/)
  visit "/users/password/edit?#{confirm_token}"
end

# Check reset password email content.
def check_resetpwd_email(user_email)
  @email = ActionMailer::Base.deliveries.first
  expect(@email.from.first).to eq("do-not-reply@pcloud.ecoworkinc.com")
  expect(@email.to.first).to eq(user_email)
  expect(@email.body).to have_content(I18n.t("devise.mailer.reset_password_instructions.instruction"))
  expect(@email.body).to match(/\/users\/password/)
end

def filled_in_email(email)
  fill_in I18n.t("user.labels.email"), with: email
end