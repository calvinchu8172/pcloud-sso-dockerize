When(/^client send a POST request to \/user\/1\/register with:$/) do |table|
  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/user/1/register"

  id = data["id"]
  password = data["password"]

  certificate_serial = @certificate.serial

  signature = create_signature(id, certificate_serial)
  signature = "" if data["signature"].include?("INVALID")

  post path, {
    id: id,
    password: password,
    certificate_serial: certificate_serial,
    signature: signature
  }
end

Given(/^an existing user with:$/) do |table|
  data = table.rows_hash
  email = data["id"]
  password = data["password"]
  FactoryGirl.create(:api_user, email: email, password: password, password_confirmation: password)
end