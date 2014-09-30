Given(/^a user visits home page$/) do
  visit unauthenticated_root_path
end

When(/^the user click sign in with Facebook link$/) do
  set_omniauth
end

When(/^the user did not grant permission$/) do
  oauth_mocking_failure
  click_link "Facebook"
end

Then(/^the user should see oauth feature "(.*?)" message$/) do |message|
  expect(page.body).to have_content(message)
end

When(/^the user grant permission$/) do
  oauth_mocking_success
  click_link "Facebook"
end

Then(/^the user will redirect to Terms of Use page$/) do
  expect(page.current_path).to eq("/oauth/new")
end

Then(/^the user should login$/) do
  check('user[agreement]')
  click_button I18n.t("labels.confirm")
end

Then(/^redirect to dashboard\/search devices page$/) do
  expect(page.current_path).to eq("/discoverer/index")
end

def set_omniauth(opts = {})
  default = {:provider => :facebook,
             :uuid     => "1234",
             :facebook => {
                            :email => "personal@example.com",
                          }
            }

  @credentials = default.merge(opts)
  @provider = @credentials[:provider]
  @user_hash = @credentials[@provider]

  OmniAuth.config.test_mode = true
end

def oauth_mocking_success
  OmniAuth.config.mock_auth[@provider] = OmniAuth::AuthHash.new({
    'uid' => @credentials[:uuid],
    "extra" => {
    "user_hash" => {
      "email" => @user_hash[:email],
      "agreement" => "1"
      }
    }
  })
  user = TestingHelper.create_and_signin
  FactoryGirl.create(:identity, user_id: user.id, provider: @provider, uid: @credentials[:uuid])
end

def oauth_mocking_failure
  OmniAuth.config.mock_auth[@provider] = :invalid_credentials
end