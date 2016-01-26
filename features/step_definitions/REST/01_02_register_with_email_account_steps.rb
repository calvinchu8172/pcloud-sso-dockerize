When(/^client send a POST request to \/user\/1\/register with:$/) do |table|

  ActionMailer::Base.deliveries.clear

  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/user/1/register"

  puts "Client sends data: #{data}"

  @email = id = data["id"]
  password = data["password"]

  certificate_serial = @certificate.serial

  puts "Client sends certificate_serial: #{certificate_serial}"

  signature = create_signature(id, certificate_serial)

  puts "Clent sends signature: #{signature}"
  # binding.pry

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


# When(/^client sends a POST request to \/user\/1\/register with:$/) do |table|

#   certificate = File.read('features/support/certificate.txt')
#   Api::Certificate.create(serial: "1002", content: certificate)
#   # binding.pry

#   ActionMailer::Base.deliveries.clear

#   data = table.rows_hash
#   path = '//' + Settings.environments.api_domain + "/user/1/register"

#   @email = id = data["id"]
#   password = data["password"]
#   certificate_serial = '1002'
#   uuid = 'due84k39-eid7-urj3-epd9-wgsyehdurj37'
#   data_send = id + certificate_serial.to_s


#   digest = OpenSSL::Digest::SHA224.new
#   # private_key = OpenSSL::PKey::RSA.new(private_key_file)
#   private_key = OpenSSL::PKey::RSA.new(File.read('features/support/private_key.txt'))
#   signature = Base64::encode64(private_key.sign(digest, data_send))
#   # binding.pry

#   header 'Accept-Language', data["Accept-Language"]
#   # binding.pry

#   post path, {
#     id: id,
#     password: password,
#     certificate_serial: certificate_serial,
#     # uuid: uuid,
#     signature: signature
#   }

# end