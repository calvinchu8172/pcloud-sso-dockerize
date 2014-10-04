Given(/^a user visits home page$/) do
  visit unauthenticated_root_path
end

Given(/^the user was not a member$/) do
  set_omniauth
end

Given(/^the user was a member$/) do
  @user = TestingHelper.create_and_confirm
  # @identity = FactoryGirl.create(:identity, user_id: @user.id, provider: "facebook", uid: "1234")
  set_omniauth(@user.email)
end

When(/^the user click sign in with Facebook link and grant permission$/) do
  click_link "Facebook"
end

When(/^the user click sign in with Facebook link and not grant permission$/) do
  set_invalid_omniauth
  click_link "Facebook"
end

When(/^the user click sign in with Facebook link$/) do
  click_link "Facebook"
end

Then(/^the user should see oauth feature "(.*?)" message$/) do |message|
  expect(page.body).to have_content(message)
end

When(/^the user grant permission$/) do
  # do nothing
end

Then(/^the user will redirect to Terms of Use page$/) do
  expect(page.current_path).to eq("/oauth/new")
end

Then(/^the user should login$/) do
  find("label.check_icon").click
  find("input#user_agreement").set(true)
  click_button "Confirm"
end

Then(/^redirect to My Devices\/Search Devices page$/) do
  expect(page.current_path).to eq("/discoverer/index")
end

def set_omniauth(email = "personal@example.com", opts = {})
  default = {provider: :facebook,
             uuid:      "1234",
             facebook: {
                         email: email,
                         gender: "male",
                         first_name: "eco",
                         last_name: "work",
                         name: "ecowork",
                         locale: "en"
                       }
            }

  credentials = default.merge(opts)
  provider = credentials[:provider]
  user_hash = credentials[provider]

  OmniAuth.config.test_mode = true

  OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash.new({
      "uid" => credentials[:uuid],
      "provider" => credentials[:provider],
      "info" => {
        "email" => user_hash[:email],
        "first_name" => user_hash[:first_name],
        "last_name" => user_hash[:last_name],
        "name" => user_hash[:name]
      },
      "extra" => {
        "raw_info" => {
          "gender" => user_hash[:gender],
          "locale" => user_hash[:locale]
        }
      }
  })
end

def set_invalid_omniauth(opts = {})

  credentials = { provider: :facebook,
                  invalid: :invalid_crendentials
                 }.merge(opts)

  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[credentials[:provider]] = credentials[:invalid]

end