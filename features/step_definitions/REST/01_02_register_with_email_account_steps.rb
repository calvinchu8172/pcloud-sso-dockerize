When(/^client send a POST request to \/user\/1\/register with:$/) do |table|

  ActionMailer::Base.deliveries.clear

  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/user/1/register"

  @email = id = data["id"]
  password = data["password"]

  certificate_serial = @certificate.serial

  signature = create_signature(id, certificate_serial)

  signature = "" if data["signature"].include?("INVALID")

  header 'Accept-Language', data["Accept-Language"]

  post path, {
    id: id,
    password: password,
    certificate_serial: certificate_serial,
    signature: signature
  }
end

Then(/^Portal's language should be changed to "(.*?)"$/) do |language|
  user = User.find_by_email(@email)
  expect(I18n.locale).to eq(language.to_sym)
  expect(user.language).to eq(language)
end