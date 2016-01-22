Given(/^an existing user's account and password$/) do
  @user = FactoryGirl.create(:api_user,
    email: "acceptance@ecoworkinc.com",
    password: "secret123",
    password_confirmation: "secret123")
end

Then(/^the JSON response should include:$/) do |attributes|
  body_hash = JSON.parse(last_response.body)
  attributes = JSON.parse(attributes)

  attributes.each do |attribute|
    expect(body_hash.key?(attribute)).to be true
  end
end

Given(/^an existing user with:$/) do |table|
  data = table.rows_hash
  email = data["id"]
  password = data["password"]
  FactoryGirl.create(:api_user, email: email, password: password, password_confirmation: password)
end

Given(/^a signed in client$/) do
  @user = TestingHelper.create_and_confirm(FactoryGirl.create(:api_user))
end

Then(/^the JSON response should include (\d+):$/) do |record_count, attributes|

  body_array = JSON.parse(last_response.body)
  expect(body_array.count).to eq(record_count.to_i)

  attributes = JSON.parse(attributes)

  body_array.each do |body|
    attributes.each do |attribute|
      expect(body.key?(attribute)).to be true
    end
  end
end

Then(/^the response status should be "(.*?)"$/) do |status_code|
  puts "*****#{last_response.status}"
  puts "*****#{last_response.body}"
  expect(last_response.status).to eq(status_code.to_i)
end

Then(/^the JSON response should include valid invitation_key$/) do
  body = JSON.parse(last_response.body)
  expect(body["invitation_key"]).to eq(Invitation.first.key)
end

Then(/^the JSON response should include error code: "(.*?)"$/) do |error_code|
  body = JSON.parse(last_response.body)
  expect(body["error_code"]).to eq(error_code)
end

Then(/^the JSON response should include description: "(.*?)"$/) do |description|
  body = JSON.parse(last_response.body)
  expect(body["description"]).to eq(description)
end

Given(/^an existing certificate and RSA key$/) do
  create_certificate_and_rsa_key
end

Then(/^the JSON response should be$/) do |response|
  expect(JSON.parse(last_response.body)).to eq(JSON.parse(response))
end

Then(/^Email deliveries should be (\d+)$/) do |count|
  expect(ActionMailer::Base.deliveries.count).to eq(count.to_i)
end

When(/^the device's IP is "(.*?)"$/) do |ip|
  ENV['RAILS_TEST_IP_ADDRESS'] = ip
end

Then(/^the database should have the same IP record$/) do
  @record = Device.find_by(mac_address: @device["mac_address"])
  decoded_ip = IPAddr.new(@record.ip_address.to_i(16), Socket::AF_INET).to_s
  expect(decoded_ip).to eq(ENV['RAILS_TEST_IP_ADDRESS']), "expected #{ENV['RAILS_TEST_IP_ADDRESS']}, but got #{decoded_ip}"
end

def create_certificate_and_rsa_key
  @rsa_key = OpenSSL::PKey::RSA.new(2048)

  cert = OpenSSL::X509::Certificate.new
  cert.version = 2
  cert.serial = 0
  cert.not_before = Time.now
  cert.not_after = Time.now + 365*24*60*60

  cert.public_key = @rsa_key.public_key
  cert.subject = OpenSSL::X509::Name.parse 'CN=nobody/DC=example'

  @certificate = Api::Certificate.create(serial: "serial_name", content: cert.to_pem)
end

def create_signature(*arg)
  data = arg.map { |param| param.to_s}.join('')

  digest = OpenSSL::Digest::SHA224.new
  private_key = @rsa_key
  #signature = CGI::escape(Base64::encode64(private_key.sign(digest, data)))
  signature = Base64::encode64(private_key.sign(digest, data))
end
