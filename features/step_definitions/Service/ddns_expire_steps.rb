Given(/^an user who has a device and pairing$/) do
  @user = FactoryGirl.build(:api_user)
  @user.skip_confirmation!
  @user.save

  TestingHelper::create_product_table if Product.count == 0
  @device = FactoryGirl.create(:api_device, product: Product.first)
  FactoryGirl.create(:pairing, user: @user, device: @device)

  ActionMailer::Base.deliveries.clear
end

Given(/^device has been not used more than (\d+) days$/) do |day_num|
  @ddns = FactoryGirl.create(:ddns, ip_address: "1.1.1.1", hostname: "test", domain: Domain.first, device: @device)
  Services::DdnsExpire.create_route53_record(@ddns)

  xmpp_last = XmppLast.find_or_initialize_by(username: @device.xmpp_username)

  xmpp_last.update(
    last_signin_at: (day_num.to_i + 1).days.ago.to_i,
    last_signout_at: day_num.to_i.days.ago.to_i,
    state: "")

end

When(/^ddns expire scan$/) do
  Services::DdnsExpire.notice
  Services::DdnsExpire.delete
end

Then(/^user should receive a warning email$/) do
  expect(ActionMailer::Base.deliveries.count).to eq(1)
end

Then(/^ddns record should still exist$/) do
  expect(@device.reload.ddns).to be_present
end

Given(/^user has received warning email on previous scan$/) do
  @device.ddns.update(status: 1, ip_address: @device.ddns.get_ip_addr)
end

Then(/^ddns record should be deleted$/) do
  expect(@device.reload.ddns).to be nil
end

Then(/^user should not receive any warning email$/) do
  expect(ActionMailer::Base.deliveries.count).to eq(0)
end
