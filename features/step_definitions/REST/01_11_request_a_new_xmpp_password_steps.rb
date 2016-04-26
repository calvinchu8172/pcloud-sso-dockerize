When(/^client send a PUT request to \/user\/1\/xmpp_account with:$/) do |table|

  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/user/1/xmpp_account"

  cloud_id = data["cloud_id"].include?("INVALID") ? "" : @user.encoded_id
  authentication_token = check_authentication_token(data["authentication_token"])
  certificate_serial = @certificate.serial

  signature = create_signature(cloud_id, authentication_token, certificate_serial)
  signature = "" if data["signature"].include?("INVALID")

  put path, {
    cloud_id: cloud_id,
    authentication_token: authentication_token,
    certificate_serial: certificate_serial,
    signature: signature
  }

end
