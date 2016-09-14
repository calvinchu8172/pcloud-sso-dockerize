

# ------------------------------------- #
# -------- device registration -------- #
# ------------------------------------- #

Given(/^the device with information$/) do |table|
  TestingHelper::create_product_table if Product.count == 0
  @device_given_attrs = table.rows_hash
  reset_signature(@device_given_attrs)
end

Given(/^the device is registered$/) do
  @is_device_registered = true
  model_class_name = @device_given_attrs['model_name'].blank? ? 'NAS325' : @device_given_attrs['model_name']
  product = Product.find_by(model_class_name: model_class_name)

  # Todo: 
  # 1. 把 ip_encode_hex、ip_decode_hex 另外拉出單獨的 utility class 處理 
  # 2. Device before_save 應該執行 ip_encode_hex
  current_ip = Api::Device.new(current_ip_address: @device_given_attrs['ip_address']).ip_encode_hex

  @registered_device = Device.create(
    mac_address: @device_given_attrs['mac_address'],
    serial_number: @device_given_attrs['serial_number'],
    firmware_version: @device_given_attrs['firmware_version'],
    ip_address: current_ip,
    product_id: product.id
    )
end

Given(/^the device is not registered$/) do 
  @is_device_registered = false

  device = Device.find_by(
    mac_address: @device_given_attrs['mac_address'], 
    serial_number: @device_given_attrs['serial_number']
    )
  expect(device).to be_nil

  username = get_device_xmpp_username(@device_given_attrs)
  xmpp_account = get_device_xmpp_username_with_host(@device_given_attrs)
  xmpp_user = XmppUser.find_by(username: username)
  expect(XmppUser.find_by(username: username)).to be_nil
end

Given(/^the device module information$/) do
  @device_given_attrs["module"] = '[{"name": "DDNS", "ver": "1" }, {"name": "pairing", "ver": "button"}]'
end

When(/^the device's IP is "(.*?)"$/) do |ip|
  ENV['RAILS_TEST_IP_ADDRESS'] = ip
end

When(/^the device "(.*?)" was be changed to "(.*?)"$/) do |key, value|
  @device_given_attrs["#{key}"] = value

  if key == 'ip_address'
    puts "original IP: #{ENV['RAILS_TEST_IP_ADDRESS']}"
    steps %{ When the device's IP is "#{value}" }
  end

  # if the invalid signature is not specified  
  reset_signature(@device_given_attrs) if key != 'signature'

  # if the invalid signature is specified  
  @invalid_signature = true if key == 'signature'
end

Then(/^the API should return success respond$/) do
  expect(last_response.status).to eq(200)
end

Then(/^the database does not have record$/) do
  steps %{ And the device is not registered }
end

Then(/^the record in databases as expected$/) do
  @result = JSON.parse(last_response.body)
  check_rest_result_valid(@device_given_attrs, @result)
end

Then(/^the database should not have any pairing records$/) do
  device = Device.find_by(mac_address: @device_given_attrs["mac_address"])
  pairing = Pairing.find_by(device_id: device.id)
  expect(pairing).to be_nil
end

Then(/^the database should not have any associate invitations and accepted users records$/) do
  device = Device.find_by(mac_address: @device_given_attrs["mac_address"])
  invitations = Invitation.find_by(device_id: device.id)
  expect(invitations).to be_nil

  accepted_users = AcceptedUser.find_by(invitation_id: @invitation_id)
  expect(accepted_users).to be_nil
end

# ------------------------ #
# -------- others -------- #
# ------------------------ #

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

Then(/^the API should return "(.*?)" and "(.*?)" with "(.*?)" responds$/) do |http, json, type|
  @result = JSON.parse(last_response.body)
  expect(last_response.status).to eq(http.to_i)
  puts "@result: #{@result}"

  key = "error" if type == "error"
  key = "result" if type == "failure"
  puts "key: #{key}"
  expect(@result[key]).to eq(json)
end

Then(/^the device record in database should have the same IP$/) do
  @record = Device.find_by(mac_address: @device_given_attrs["mac_address"])
  decoded_ip = IPAddr.new(@record.ip_address.to_i(16), Socket::AF_INET).to_s
  expect(decoded_ip).to eq(ENV['RAILS_TEST_IP_ADDRESS']), "expected #{ENV['RAILS_TEST_IP_ADDRESS']}, but got #{decoded_ip}"
end


# --------------------------- #
# -------- functions -------- #
# --------------------------- #

def create_certificate_and_rsa_key
  @rsa_key = OpenSSL::PKey::RSA.new(2048)
  name = OpenSSL::X509::Name.parse 'CN=nobody/DC=example'

  cert = OpenSSL::X509::Certificate.new
  cert.version = 2
  cert.serial = 0
  cert.not_before = Time.now
  cert.not_after = Time.now + 365*24*60*60

  cert.public_key = @rsa_key.public_key
  cert.subject = name

  cert.sign(@rsa_key, OpenSSL::Digest::SHA1.new)

  @certificate = Api::Certificate.create(serial: "serial_name", content: cert.to_pem, vendor_id: 1)
end

def create_signature(*arg)
  data = arg.map { |param| param.to_s}.join('')

  digest = OpenSSL::Digest::SHA224.new
  private_key = @rsa_key
  #signature = CGI::escape(Base64::encode64(private_key.sign(digest, data)))
  signature = Base64::encode64(private_key.sign(digest, data))
end

def check_authentication_token(authentication_token)
  if authentication_token == "VALID AUTHENTICATION TOKEN"
    authentication_token = @user.create_authentication_token
  elsif authentication_token == "VALID ACCESS TOKEN"
    access_token = Doorkeeper::AccessToken.create(:application_id => 1, :resource_owner_id => @user.id, :expires_in => 21600, scopes: "")
    authentication_token = access_token.token
  elsif authentication_token == "REVOKED ACCESS TOKEN"
    access_token = Doorkeeper::AccessToken.create(:application_id => 1, :resource_owner_id => @user.id, :expires_in => 21600, :revoked_at => Time.now, scopes: "")
    authentication_token = access_token.token
  elsif authentication_token == "EXPIRED ACCESS TOKEN"
    access_token = Doorkeeper::AccessToken.create(:application_id => 1, :resource_owner_id => @user.id, :expires_in => 21600, :created_at => Time.at(Time.now.to_i - 21700), scopes: "")
    authentication_token = access_token.token
  elsif authentication_token.include?("INVALID")
    authentication_token = ""
  else
    authentication_token = ""
  end
end

def get_device_xmpp_username(device)
  username = 'd' + device["mac_address"].gsub(':', '-') + '-' + device["serial_number"].gsub(/([^\w])/, '-')
  username
end

def get_device_xmpp_username_with_host(device)
  "#{get_device_xmpp_username(device)}@#{Settings.xmpp.server}/#{Settings.xmpp.device_resource_id}"
end

def check_rest_result_valid(device, result)
  
  username = get_device_xmpp_username(device)
  xmpp_account = get_device_xmpp_username_with_host(device)
  
  # Check json result
  expect(result["xmpp_account"]).to eq(xmpp_account)
  expect(result["xmpp_bots"]).to eq(Settings.xmpp.bots)
  expect(result["xmpp_ip_addresses"]).to eq(Settings.xmpp.nodes)

  # Check xmpp db record
  db_user = XmppUser.find_by(username: username)
  expect(db_user.username).to eq(username)
  expect(db_user.password).not_to be_empty

  # Check redis record
  redis = Redis.new(:host => Settings.redis.web_host, :port => Settings.redis.port, :db => 0 )
  device_id = redis.GET("xmpp:#{username}:session")
  device_session = Device.find(device_id).session.all
  expect(device_session["xmpp_account"]).to eq(username)

  # Check device module session
  unless device['module'].blank?
    expect(Device.first.module_version.all).to eq({"ddns" => "1", "pairing" => "button"})
  end

  # Check signin_at column of xmpp_last record
  username = Api::Device.first.xmpp_username
  expect(XmppLast.find_by(username: username).last_signin_at).to be_present

  if ENV['RAILS_TEST_IP_ADDRESS'].nil?
    expect(device_session["ip"]).to eq('127.0.0.1')
  else
    #Check device ip address changed
    device = Device.find(device_id)
    expect(device.ip_decode_hex).to eq(ENV['RAILS_TEST_IP_ADDRESS']), "expected #{ENV['RAILS_TEST_IP_ADDRESS']}, but got #{device.ip_decode_hex}"
    expect(device_session["ip"]).to eq(ENV['RAILS_TEST_IP_ADDRESS']), "expected #{ENV['RAILS_TEST_IP_ADDRESS']}, but got #{device_session['ip']}"
  end

end

def reset_signature(device)
  magic_number = Settings.magic_number
  data = device["mac_address"] + device["serial_number"].to_s + device["model_name"] + device["firmware_version"] + magic_number.to_s
  sha224 = OpenSSL::Digest::SHA224.new
  @device_given_attrs["signature"] = sha224.hexdigest(data)
  @device_given_attrs
end

def create_rest_pairing(device)

  # redis = Redis.new
  redis = Redis.new(:host => Settings.redis.web_host, :port => Settings.redis.port, :db => 0 )
  pairing = Pairing.new
  pairing.device = device
  pairing.user = TestingHelper.create_and_signin
  pairing.ownership = 0
  puts 'pairing:' + pairing.attributes.to_s
  pairing.save
end


