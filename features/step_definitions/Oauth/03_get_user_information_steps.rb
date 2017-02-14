When(/^client send a GET request to \/api\/v(\d+)\/my\/info with:$/) do |arg1, table|

  data = table.rows_hash
  path = '//' + Settings.environments.api_domain + "/api/v1/my/info"

  if data["access_token"].include?("INVALID")
    access_token = "invalid access_token"
  else
    access_token = @oauth_access_token.token
  end

  get path, {
    access_token: access_token
  }
end

Then(/^the JSON response should include error:$/) do |attributes|
  attributes = JSON.parse(attributes)
  attributes.each do |attribute|
   expect(last_response.header["WWW-Authenticate"]).to have_content(attribute)
  end
end