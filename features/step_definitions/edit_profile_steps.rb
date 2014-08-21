include Warden::Test::Helpers
Warden.test_mode!

# Sign Account and Go to Profile page
Given(/^a user visits profile page$/) do
  @user = create_and_signin
  visit "/personal/profile"
end

Given(/^the user visits "(.*?)" page$/) do |link|
  click_link link
end

Given(/^the user clean the display name$/) do
  fill_in "Display as", with: ""
end

Given(/^the user changed the display name$/) do
  @display_name = "Tester"
  fill_in "Display as", with: @display_name
end

When(/^the user click "(.*?)" button$/) do |button|
  click_button button
end

# -------------------------------------------------------------------
# -------------------------- Expect result --------------------------
# -------------------------------------------------------------------
Then(/^the user should see profile$/) do
  expect(page).to have_content(@user.email)
  expect(page).to have_content(@user.language)
end

Then(/^the user should see the error message under the "Display as"$/) do
  expect(page).to have_selector('div.input_error input[name="user[display_name]"]' )
  expect(page).to have_content("can't be blank")
end

Then(/^the user's profile has been updated$/) do
  expect(page).to have_content(@display_name)
end

Then(/^display successfully information on profile page$/) do
  expect(page.current_path).to eq("/personal/profile")
  expect(page.body).to have_content(I18n.t("devise.registrations.updated"))
end

def create_and_signin
  user = FactoryGirl.create(:user)
  user.confirm!
  user.save
  login_as(user, scope: :user)
  user
end