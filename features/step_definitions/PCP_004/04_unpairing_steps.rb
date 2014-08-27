Given(/^a user have pairing device$/) do
  @user = TestingHelper.create_and_signin
  @pairing = TestingHelper.create_pairing(@user.id)
end

# -------------------------------------------------------------------
# ---------------------------    input   ----------------------------
# -------------------------------------------------------------------

When(/^the user visit device unpairing page$/) do
  visit "/unpairing/index/#{@pairing.id}"
end

When(/^the user click "Confirm" button in pairing page$/) do
  click_link I18n.t("labels.confirm")
end

# -------------------------------------------------------------------
# ---------------------------   output   ----------------------------
# -------------------------------------------------------------------

Then(/^the user should see unpairing feature "(.*?)" message$/) do |msg|
  expect(page).to have_content(msg)
end

