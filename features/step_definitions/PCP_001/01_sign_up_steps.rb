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
  TestingHelper.setup_test_email
end

Given(/^the email has been existed$/) do
  @user = FactoryGirl.create(:user)
end

Given(/^the visitor filled the user information$/) do
  fill_in "E-mail", with: @user.email
  fill_in "Password", with: "12345678"
  fill_in "Confirm Password", with: "12345678"
end


Given(/^the visitor success sign up and login$/) do
  steps %{
    When the visitor success sign up an account:
      | E-mail            | personal@example.com   |
      | Password          | 12345678               |
      | Confirm Password  | 12345678               |

    Then the page will redirect to success page
    And one new user created by personal@example.com
    And the new user should receive an email confirmation

    When the new user confirmed account within email

    Then the page will redirect to confirmed page

    When user click the confirm button

    Then user will redirect to login page
  }
end


Given(/^the user click sign out button$/) do
  logout(:user)
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
  TestingHelper.setup_test_email
  click_button I18n.t("labels.sign_up")

  # Check user info store in DB is correctly
  user_info = table.rows_hash
  expect(user_info["E-mail"]).to eq(User.find_by(email: user_info["E-mail"]).email)
end

When(/^the user try to sign in$/) do
  visit new_user_session_path
  fill_in "user[email]", with: "personal@example.com"
  fill_in "user[password]", with: "12345678"
  find('.zyxel_btn_login_submit').click
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
  expect(page).to have_content("success")
end

# Check user account status, the new account should be saved
Then(/^one new user created by (.*?)$/) do |account|
  @email = account
  user = User.find_by_email(@email)
  expect(user).to be_present
  expect(user.confirmation_token).to be_present
end

# Check confirmation email status
Then(/^the new user should receive an email confirmation$/) do
  check_email_content(@email)
end

# Check content for sent email page
Then(/^the user should see "(.*?)" button$/) do |btn|
  expect(page).to have_link(btn)
end

Then(/^user will visit page containing "(.*?)"$/) do |title|
  expect(page).to have_content(title)
end

Then(/^user should not see "(.*?)" button$/) do |btn|
  expect(page).to have_no_link(btn)
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

Then(/^the page will redirect to login page$/) do
  expect(page.current_path).to eq(new_user_session_path)
end

When(/^user click the confirm button$/) do
  click_link I18n.t("labels.confirm")
end

Then(/^user will auto login and redirect to dashboard$/) do
  expect(page.current_path).to eq("/discoverer/index")
end

Then(/^user will login and redirect to dashboard$/) do
  expect(page.current_path).to eq("/discoverer/index")
end

Then(/^user will redirect to login page$/) do
  expect(page).to have_content("Sign in")
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

# Check Confirmation email content.
def check_email_content(user_email)
  @email = ActionMailer::Base.deliveries.first
  expect(@email.from.first).to eq(ActionMailer::Base.default[:from])
  expect(@email.to.first).to eq(user_email)
  expect(@email.body).to have_content("You have registered a new account at mycloud.zyxel.com")
  expect(@email.body).to match(/\/users\/confirmation/)
end
