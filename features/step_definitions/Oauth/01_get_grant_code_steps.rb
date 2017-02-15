Given(/^an oauth client user exists to get grant code$/) do
  @oauth_client_user = FactoryGirl.create(:oauth_user)
end

Given(/^(\d+) existing client app$/) do |arg1|
  @oauth_client_app = FactoryGirl.create(:oauth_client_app)
  # @oauth_access_token = FactoryGirl.create(:oauth_access_token, resource_owner_id: @oauth_client_user.id, application_id: @oauth_client_app.id, use_refresh_token: true)
  @client_id = @oauth_client_app.uid
  @secret = @oauth_client_app.secret
  @redirect_uri = @oauth_client_app.redirect_uri
end

Given(/^user visits authorization page$/) do
  visit "/oauth/authorize?client_id=#{@client_id}&redirect_uri=#{@redirect_uri}&response_type=code&theme=yellow&locale=zh_TW"
end

Given(/^the user filled the correct login information$/) do
  puts @oauth_client_user
  puts @oauth_client_user.email
  fill_in "user[email]", with: @oauth_client_user.email
  fill_in "user[password]", with: @oauth_client_user.password
end

When(/^the user click "(.*?)" button aa$/) do |button|
  click_button button
  color = page.evaluate_script("$('.content_wrapper').css('background-color')")
end

Then(/^user will be redirect to his app url with grant code\.$/) do
  expect(current_url).to eq(@oauth_client_app.redirect_uri + '?code=' + @oauth_client_app.access_grants.last.token)
end

Then(/^user will be redirect to his app url with deny message$/) do
  expect(current_url).to eq(@oauth_client_app.redirect_uri + '?error=access_denied&error_description=The+resource+owner+or+authorization+server+denied+the+request.')
end


Given(/^user visits authorization page with wrong (.*?)$/) do |params|	
  visit "/oauth/authorize?client_id=#{params}&redirect_uri=#{@redirect_uri}&response_type=code" if params == 'invalid_client_id'
  visit "/oauth/authorize?client_id=#{@client_id}&redirect_uri=#{params}&response_type=code" if params == 'invalid_redirect_uri'
  visit "/oauth/authorize?client_id=#{@client_id}&redirect_uri=#{@redirect_uri}&response_type=#{params}" if params == 'invalid_response_type'
end

Then(/^user see the (.*?) on page$/) do |error_message|	
  expect(page).to have_content(I18n.t("doorkeeper.authorizations.error.title"))
  expect(page).to have_content(I18n.t("doorkeeper.errors.messages.invalid_client")) if error_message == 'invalid_client'
  expect(page).to have_content(I18n.t("doorkeeper.errors.messages.invalid_redirect_uri")) if error_message == 'invalid_redirect_uri'
  expect(page).to have_content(I18n.t("doorkeeper.errors.messages.unsupported_response_type")) if error_message == 'unsupported_response_type'
end


Given(/^user visits authorization page with (.*?) theme$/) do |color|
  visit "/oauth/authorize?client_id=#{@client_id}&redirect_uri=#{@redirect_uri}&response_type=code&theme=#{color}"
end

Then(/^the theme color is (.*?)$/) do |color|
  expect(color).to eq(color)
end

# 00B2FF blue
# 64BE00 green
# FFC803 yellow
# FF8A03 orange
# FF2938 red
