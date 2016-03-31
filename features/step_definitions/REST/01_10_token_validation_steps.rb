When(/^client send a GET request to \/user\/1\/token with:$/) do |table|

  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/user/1/token"

  cloud_id = data["cloud_id"].include?("INVALID") ? "" : @user.encoded_id
  if data["authentication_token"] == "VALID AUTHENTICATION TOKEN"
    authentication_token = @user.create_authentication_token
  elsif data["authentication_token"] == "VALID ACCESS TOKEN"
    access_token = Doorkeeper::AccessToken.create(:application_id => 1, :resource_owner_id => @user.id, :expires_in => 21600, scopes: "")
    authentication_token = access_token.token
  elsif data["authentication_token"] == "REVOKED ACCESS TOKEN"
    access_token = Doorkeeper::AccessToken.create(:application_id => 1, :resource_owner_id => @user.id, :expires_in => 21600, :revoked_at => Time.now, scopes: "")
    authentication_token = access_token.token
  elsif data["authentication_token"] == "EXPIRED ACCESS TOKEN"
    access_token = Doorkeeper::AccessToken.create(:application_id => 1, :resource_owner_id => @user.id, :expires_in => 21600, :created_at => Time.at(Time.now.to_i - 21700), scopes: "")
    authentication_token = access_token.token
  else
    authentication_token = ""
  end

  # authentication_token = data["authentication_token"].include?("INVALID") ? "" : @user.create_authentication_token
  get path, {
    cloud_id: cloud_id,
    authentication_token: authentication_token
  }
end