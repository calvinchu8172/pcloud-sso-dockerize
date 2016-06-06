Given(/^the user visits unpairing page$/) do
  visit "/unpairing/index/#{@pairing.device.encoded_id}"
end

Given(/^the user successfully unpair device$/) do
  steps %{
    When the user click "Confirm" link

    Then the user will redirect to success page
    And the user should see success message
    And the record of pairing should be removed
  }
end

When(/^the user have not other devices$/) do
  # do nothing
end

Then(/^the user should see confirm message on unpairing confirm page$/) do
  expect(page).to have_content I18n.t("warnings.settings.unpairing.instruction")
  expect(page).to have_link I18n.t("labels.confirm")
  expect(page).to have_link I18n.t("labels.cancel")
end

Then(/^the user should see success message$/) do
  expect(page).to have_content I18n.t("warnings.settings.unpairing.success")
end

Then(/^the user will redirect to success page$/) do
  expect(page.current_path).to eq "/unpairing/success/#{@pairing.device.encoded_id}"
end

Then(/^the user will redirect to Search Device page$/) do
  expect(page.current_path).to eq "/discoverer/index"
end

Then(/^the record of pairing should be removed$/) do
  expect(Pairing.exists?(@pairing.id)).to be false
end

Then(/^the device relations of invitations and accepted_users are all deleted$/) do
  expect(Invitation.count).to eq(0)
  expect(AcceptedUser.count).to eq(0)
end

Then(/^the device has inviation and accepted_user$/) do
  user = FactoryGirl.create(:user)
  pairing = TestingHelper.create_pairing(user.id, Device.first)
  invitation = TestingHelper.create_invitation(user, user.pairings.first.device)
  @invitation_id = invitation.id

  another_user = FactoryGirl.create(:user)
  invitation.accepted_by(another_user.id)
end