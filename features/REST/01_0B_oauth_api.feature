Feature: [REST_01_0B] Cross test for Oauth

  Scenario: [REST_01_0B_01]
    Client already registered by facebook, but checkin by google
    Given the client has access token and uuid from facebook
      And an existing certificate and RSA key
      And client has registered in Rest API by facebook account and password "test_password"
      And this account is already binding to "facebook"
     When client send a GET request to /user/1/checkin/google with:
      | user_id      | USER ID      |
      | access_token | ACCESS TOKEN |
    Then the response status should be "400"
      And the JSON response should include error code: "002"
      And the JSON response should include description: "not binding yet"

  Scenario: [REST_01_0B_02]
    Client already registered by facebook, but register by google
    Given the client has access token and uuid from facebook
      And an existing certificate and RSA key
      And client has registered in Rest API by facebook account and password "test_password"
      And this account is already binding to "facebook"
     When client send a POST request to /user/1/register/google with:
      | user_id      | USER ID       |
      | access_token | ACCESS TOKEN  |
      | password     | test_password |
      | signature    | SIGNATURE     |
    Then the response status should be "200"
      And the JSON response should include:
      """
      ["user_id", "account_token", "authentication_token", "timeout", "confirmed", "registered_at", "bot_list", "xmpp_ip_addresses", "stun_ip_addresses", "xmpp_account"]
      """
