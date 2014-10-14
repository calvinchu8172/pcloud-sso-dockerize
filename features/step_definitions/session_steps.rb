include Warden::Test::Helpers
Warden.test_mode!

module TestingHelper
  def self.setup_test_email
    # make your delivery state to 'test' mode
    ActionMailer::Base.delivery_method = :test
    # make sure that actionMailer perform an email delivery
    ActionMailer::Base.perform_deliveries = true
    # clear all the email deliveries, so we can easily checking the new ones
    ActionMailer::Base.deliveries.clear
  end
  def self.signin_user(user)
    login_as(user, scope: :user)
  end
  def self.create_and_confirm
    user = FactoryGirl.create(:user)
    user.confirm!
    user.save
    user
  end
  def self.create_device
    product_id = Product.first.id
    device = FactoryGirl.create(:device, product_id: product_id)
    device.save
    device.update_ip_list "127.0.0.1"
    device
  end
  def self.create_and_signin
    user = create_and_confirm
    signin_user(user)
    user
  end
  def self.create_pairing(user_id)
    device = create_device
    pairing = FactoryGirl.create(:pairing, user_id: user_id, device_id: device.id)
    pairing.save
    pairing
  end
end

# Click submit button
When(/^the user click "(.*?)" button$/) do |button|
  click_button button
end

# Click link
When(/^the user click "(.*?)" link$/) do |link|
  click_link link
end

When(/^the user have other devices$/) do
  @other_paired = TestingHelper.create_pairing(@user.id)
end

Given(/^the user have a paired device$/) do
  @user = TestingHelper.create_and_signin
  @pairing = TestingHelper.create_pairing(@user.id)
end

When(/^the user want to click link without cancel$/) do
  find("h1.header_h1_rwd > a").click
  find("a.member").click
  find("a.sign_out").click
  find("a.btn_tab_color1").click
  find("a.btn_tab_color2").click
end

Then(/^the user will redirect to My Devices page$/) do
  expect(page.current_path).to eq "/personal/index"
end

def wait_server_response
  sleep 5
end