When(/^a user visits accept invitation page$/) do
  visit "/invitations/accept/#{Invitation.first.key}"
  wait_server_response
end

Given(/^the invalid invitation key$/) do
  Invitation.first.update_attributes(key: "")
end

When(/^user logined$/) do
  @current_user = TestingHelper::create_and_signin
end

Given(/^user logined who generate invitation key$/) do
  @user.update_attributes(confirmed_at: Time.now)
  TestingHelper::signin_user(@user)
end

Given(/^connect over (\d+) sec and server send "(.*?)" message$/) do |seconds, message|
  allow_any_instance_of(InvitationsController).to receive(:timeout?).and_return(true)
end

Given(/^connect success and server send success message$/) do
  allow_any_instance_of(InvitationsController).to receive(:done?).and_return(true)
  allow_any_instance_of(InvitationsController).to receive(:session_status).and_return("done")
end

Then(/^the visitor should see a "(.*?)" message and button for "(.*?)"$/) do |message, button|
  expect(page).to have_content(message)
  expect(page).to have_link(button)
end

Given(/^user already acceped this invitation$/) do
  Invitation.first.accepted_by @current_user.id
  AcceptedUser.last.finish_accept
end

When(/^connect success but server send failure message with error code$/) do
  allow_any_instance_of(InvitationsController).to receive(:done?).and_return(true)
  allow_any_instance_of(InvitationsController).to receive(:session_status).and_return("failure")
  allow_any_instance_of(InvitationsController).to receive(:error_code).and_return("597")
end

Given(/^the invitation key expire count is zero$/) do
  Invitation.first.update_attributes(expire_count: 0)
end

When(/^user click "(.*?)" button$/) do |button|
  click_link button
end

Then(/^the user will redirect to discover page$/) do
  expect(page.current_path).to eq("/discoverer/index")
end

Then(/^user will redirect to Zyxel drive landing page$/) do
  expect(page.current_url).to eq("http://zyxel.to/zdrive.dff2")
end

Then(/^the visitor should reload this page for retry$/) do
  expect(page).to have_content "Connecting"
end

Given(/^an existing device with pairing signed in client without xmpp$/) do
  @device = TestingHelper.create_device
  FactoryGirl.create(:pairing, user_id: @user.id, device_id: @device.id)
end

Then(/^the invitation page should see an error message for "(.*?)"$/) do |message|
  expect(page).to have_content(message)
end
