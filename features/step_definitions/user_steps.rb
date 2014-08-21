# Go to sign up page
Given(/^a user visits sign up page$/) do
  visit new_user_registration_path
end

# -------------------------------------------------------------------
# ---------------- Filled in Sign Up information --------------------
# -------------------------------------------------------------------

# Check the user agreement item
Given(/^the visitor agreed the terms of use$/) do
  check('user[agreement]')
end

# Assign the invalid value to item of field text
Given(/^the visitor filled the invalid "(.*?)" (.*?)$/) do |item, value|
  fill_in item, with: value
end

# Testing for recaptcha
Given(/^the visitor filled the captcha correctly$/) do
  captcha_evaluates_to true
end
Given(/^the visitor filled the captcha incorrectly$/) do
  captcha_evaluates_to false
end

# Filled user information
Given(/^the visitor filled the user information:$/) do |table|
  # filled in information to field text on sign up page
  filled_in_info(table)
end

Given(/^the visitor filled all the required fields:$/) do |table|
  captcha_evaluates_to true
  filled_in_info(table)
  setup_test_email
end

Given(/^the email of "(.*?)" has been existed$/) do |email|
  FactoryGirl.create(:user)
end

# Click submit button with value
When(/^the visitor click "(.*?)" button$/) do |button|
  click_button button
end

# Sign up successfully
When(/^the visitor success sign up an account:$/) do |table|
  filled_in_info(table)
  check('user[agreement]')
  captcha_evaluates_to true
  setup_test_email
  click_button I18n.t("labels.sign_up")
end

# -------------------------------------------------------------------
# ---------------------- Check error message ------------------------
# -------------------------------------------------------------------

# Check and display error message for input
Then(/^the visitor should see an error message for "(.*?)"$/) do |item|
  input_name = ""
  item.downcase.split(" ").each_with_index do |value, index|
    if item.split.length == index+1
      input_name << value
    else
      input_name << value << "_"
    end
  end
  expect(page).to have_selector('div.input_error input[name="user[' + input_name + ']"]' )
  puts item + " " + find('div.zyxel_arlert_area>label.error_message').text
end

# Check and display error message for captcha
Then(/^the visitor should see an error message for Captcha code$/) do
  expect(page).to have_selector('div#dynamic_recaptcha~div.error div.zyxel_arlert_area')
  puts find('div#dynamic_recaptcha~div.error div.zyxel_arlert_area>label.error_message').text
end

# Check and display error message for checkout
Then(/^the visitor should see an error message for Terms of Use$/) do
  expect(page).to have_selector('input[name="user[agreement]"]~div.zyxel_arlert_area')
  puts "Terms of Use " + find('input[name="user[agreement]"]~div.zyxel_arlert_area>label.error_message').text
end

# -------------------------------------------------------------------
# ------------------------ Create account ---------------------------
# -------------------------------------------------------------------

# Check the sign up flow
Then(/^the page will redirect to success page$/) do
  expect(page.current_path).to eq(hint_confirm_path)
end

# Check user account status, the new account should be saved
Then(/^one new user created by (.*?)$/) do |account|
  @email = account
  user = User.find_by_email(@email)
  user.should_not be_nil
  user.confirmation_token.should_not be_nil
end

# Check confirmation email status
Then(/^the new user should receive an email confirmation$/) do
  check_email_content(@email)
end

# Check content for sent email page
Then(/^the new user should see "(.*?)" and "(.*?)" button$/) do |btn1, btn2|
  expect(page).to have_link(btn1, href: new_user_confirmation_path)
  expect(page).to have_link(btn2, href: unauthenticated_root_path)
end

# -------------------------------------------------------------------
# ------------------------ Confirm account --------------------------
# -------------------------------------------------------------------

Then(/^the new user confirmed account within email$/) do
  confirm_token = @email.body.match(/confirmation_token=[\w\-]*/)
  visit "/users/confirmation?#{confirm_token}"
end

Then(/^the page will redirect to confirmed page$/) do
  expect(page.body).to have_content(I18n.t("devise.confirmations.confirmed"))
  expect(page.body).to have_link(I18n.t("labels.confirm"), href: "/")
end

When(/^user click the confirm button$/) do
  click_link I18n.t("labels.confirm")
end

Then(/^user will auto login and redirect to dashboard$/) do
  expect(page.current_path).to eq("/discoverer/index")
end

# Analog method of captcha
def captcha_evaluates_to(result)
  eval <<-CODE
    module Recaptcha
      module Verify
        def verify_recaptcha
          #{result}
        end
      end
    end
  CODE
end

# Filled in user information
def filled_in_info(info_table)
  info_table.each_cells_row { |info|
    fill_in info.value(0), with: info.value(1)
  }
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

# Check Confirmation email content.
def check_email_content(user_email)
  @email = ActionMailer::Base.deliveries.first
  expect(@email.from.first).to eq(ActionMailer::Base.default[:from])
  expect(@email.to.first).to eq(user_email)
  expect(@email.body).to have_content(I18n.t("devise.mailer.confirmation_instructions.instruction"))
  expect(@email.body).to match(/\/users\/confirmation/)
end
