Given(/^a user sign in from APP$/) do
  @user = TestingHelper.create_and_signin
end

Given(/^the user get a authentication token already$/) do
  # @user = TestingHelper.create_and_signin
  @user.confirmation_token = Devise.friendly_token
end

Given(/^a user try to request own device list from APP$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^APP request POST to https:\/\/api\-mycloud\.zyxel\.com\/resources\/(\d+)\/device_list$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^APP will get HTTP: (\d+)$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then(/^the JSON should include \["(.*?)","(.*?)","(.*?)","(.*?)","(.*?)","(.*?)", "(.*?)"\]$/) do |arg1, arg2, arg3, arg4, arg5, arg6, arg7|
  pending # express the regexp above with the code you wish you had
end

Given(/^a client didn’t use app after sign up for more than (\d+) seconds$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given(/^the client try to request own device list from APP$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^the JSON response at "(.*?)" should be "(.*?)"$/) do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end