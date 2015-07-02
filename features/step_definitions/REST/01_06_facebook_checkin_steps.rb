Given(/^the client has access token and uuid from facebook$/) do

  # fake access_token & uuid to avoid internet request
  @access_token = "CAAUJXbpEWSEBALt3D2Jr9AWs7j8iZAYOCNFObdy4viKMnpfPhfZB5gcK00vpQMSDHBoGZAH0047NLrSwVnGUt0NqKQYOVcrqYqLgppkvwNLf0cI8IVPmRz9TkRFyNQhDyLUURehohyslfKi1ZAIU3ZAdI2Cqf6jcDQWdPtUSdpItE6CZAMM0qxsTfnZCnrk5sZB7CY0wMFP2LgZDZD"
  @uuid = "1462256724090912"

  # fake oauth_data for Api::User::OauthController::get_oauth_data to use
  @email = "test-user@facebook.com"
  @oauth_data = {
    "id"=>"1462256724090912",
    "first_name"=>"Open",
    "gender"=>"male",
    "last_name"=>"User",
    "link"=>"https://www.facebook.com/app_scoped_user_id/1462256724090912/",
    "locale"=>"en_US",
    "middle_name"=>"Graph Test",
    "name"=>"Open Graph Test User",
    "timezone"=>0,
    "updated_time"=>"2015-03-17T06:58:50+0000",
    "verified"=>false,
    "email"=> @email
  }

end

Given(/^client has registered in Rest API by facebook account and password "(.*?)"$/) do |password|
  signature = create_signature(@certificate.serial, @uuid, @access_token)
  @oauth_user = FactoryGirl.create(
    :oauth_user,
    email: @email,
    password: password,
    password_confirmation: password,
    signature: signature,
    certificate_serial: @certificate.serial,
    user_id: @uuid,
    access_token: @access_token)
end

Given(/^this account is already binding to "(.*?)"$/) do |oauth_provider|
  Identity.create(user_id: @oauth_user.id, provider: oauth_provider, uid: @uuid)
end

Given(/^client already has a portal account$/) do
  @oauth_user.update_attribute(:confirmation_token, nil)
end

When(/^client send a GET request to \/user\/1\/checkin\/facebook with:$/) do |table|
  path = '//' + Settings.environments.api_domain + "/user/1/checkin/facebook"

  data = table.rows_hash
  user_id = data["user_id"].include?("INVALID") ? "" : @uuid
  access_token = data["access_token"].include?("INVALID") ? "" : @access_token

  #get_oauth_data is already verified @ 01_0A_oauth_api.feature, so here use test double
  if user_id.blank? || access_token.blank?
    Api::User::OauthController.any_instance.stub(get_oauth_data: nil)
  else
    Api::User::OauthController.any_instance.stub(get_oauth_data: @oauth_data)
  end

  get path, {
    user_id: user_id,
    access_token: access_token
  }
end

