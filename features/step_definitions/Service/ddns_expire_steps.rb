Given(/^an user who has a device and pairing$/) do
  @user = FactoryGirl.build(:api_user)
  user.skip_confirmation!
  user.save

  @device = FactoryGirl.create(:api_device, product: Product.first)
  FactoryGirl.create(:pairing, user: user, device: @device)

  ActionMailer::Base.deliveries.clear
end

Given(/^device has been not used more than (\d+) days$/) do |day_num|
  @ddns = FactoryGirl.create(:ddns, ip_address: "1.1.1.1", hostname: "test", domain: Domain.first, device: @device)

  xmpp_last = XmppLast.find_or_create_by(username: @device.xmpp_username)
  xmpp_last.state ||= ""
  xmpp_last.update(
    last_signin_at: (day_num.to_i + 1).days.ago,
    last_signout_at: day_num.to_i.days.ago)
  xmpp_last.save

end

When(/^ddns expire scan$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^user should receive a warning email$/) do
  expect(ActionMailer::Base.deliveries.count).to eq(1)
end

Then(/^ddns record should still exist$/) do
  expect(@device.reload.ddns).to be_present
end

Given(/^user has received warning email on previous scan$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^ddns record should be deleted$/) do
  expect(@device.reload.ddns).to be nil
end

Then(/^user should not receive any warning email$/) do
  expect(ActionMailer::Base.deliveries.count).to eq(0)
end

Given(/^device has been used recently$/) do
  pending # express the regexp above with the code you wish you had
end
