Given(/^an existing certificate and RSA key$/) do
  create_certificate_and_rsa_key
end

When(/^client send a DELETE request to "(.*?)" with:$/) do |url_path, table|
  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + url_path

  device_account = data["device_account"].include?("INVALID") ? "" : @device.session['xmpp_account']
  cloud_id = data["cloud_id"].include?("INVALID") ? "" : @user.encoded_id
  certificate_serial = data["certificate_serial"].include?("INVALID") ? "" : @certificate.serial

  signature = create_signature(certificate_serial, device_account, cloud_id)
  signature = "" if data["signature"].include?("INVALID")

  delete path, {
    device_account: device_account,
    cloud_id: cloud_id,
    certificate_serial: certificate_serial,
    signature: signature
  }

end

Then(/^the JSON response should be$/) do |response|
  expect(JSON.parse(last_response.body)).to eq(JSON.parse(response))
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
  signature = CGI::escape(Base64::encode64(private_key.sign(digest, data)))
end
