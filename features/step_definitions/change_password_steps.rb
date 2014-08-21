# Set a user
Given(/^a user change the password$/) do
  @user = FactoryGirl.create(:user)
  @user.confirm!
  @user.save
end

# Set a user who visit password change page
Then(/^the user is login and visits password change page$/) do
	visit unauthenticated_root_path
	fill_in 'user_email', with: @user.email
	fill_in 'user_password', with: @user.password
	click_button I18n.t("labels.sign_in")
	visit '/users/edit?type=password'
	# find("a[@href='/personal/profile']").click   
	# click_link I18n.t("labels.change_password")
end


# -------------------------------------------------------------------
# ---------------------------    input   ----------------------------
# -------------------------------------------------------------------

When(/^the user filled the incorrect current password$/) do
  fill_in I18n.t("user.labels.current_password"), with: 'notpassword'
end

When(/^the user filled the correct current password$/) do
  fill_in I18n.t("user.labels.current_password"), with: @user.password
end

When(/^the user filled the new password <(.*?)>$/) do |password|
  fill_in I18n.t("user.labels.password"), with: password
  fill_in I18n.t("user.labels.password_confirmation"), with: password
end

When(/^the user click submit for change password$/) do
  click_button I18n.t("labels.submit")
end

# -------------------------------------------------------------------
# ---------------------------   output   ----------------------------
# -------------------------------------------------------------------

Then(/^the user will get error message from change password$/) do
	expect(page).to have_selector('.zyxel_arlert_area')
	puts find('.zyxel_arlert_area > .error_message').text
end

Then(/^the user will get success message from change password$/) do
	expect(page).to have_selector('.zyxel_smallok_area')
	puts find('.zyxel_smallok_area > span').text
end