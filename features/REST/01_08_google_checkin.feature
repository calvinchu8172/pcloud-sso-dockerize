Feature: [REST_01_08] Google Checkin

  Background:
    Given the client has access token and uuid from google
      And an existing certificate and RSA key

  Scenario: [REST_01_08_01]
    Client sign in by google uuid and access token with binding account
    Given client has registered in Rest API by google account
      And this account is already binding to "google_oauth2"
     When client send a GET request to /user/1/checkin/google with:
      | user_id      | USER ID      |
      | access_token | ACCESS TOKEN |
     Then the response status should be "200"
      And the JSON response should include:
      """
      ["result", "account"]
      """

  Scenario: [REST_01_08_02]
    Client sign in by invalid google uuid and access token with binding account
    Given client has registered in Rest API by google account
      And this account is already binding to "google_oauth2"
     When client send a GET request to /user/1/checkin/google with:
      | user_id      | INVALID USER ID      |
      | access_token | INVALID ACCESS TOKEN |
     Then the response status should be "400"
      And the JSON response should include error code: "000"
      And the JSON response should include description: "Invalid Google account"

  Scenario: [REST_01_08_03]
    Client sign in by google uuid and access token but not registered yet
     When client send a GET request to /user/1/checkin/google with:
      | user_id      | USER ID      |
      | access_token | ACCESS TOKEN |
     Then the response status should be "400"
      And the JSON response should include error code: "001"
      And the JSON response should include description: "unregistered"

  Scenario: [REST_01_08_04]
    Client sign in by google uuid and access token but not binding account yet
    Given client has registered in Rest API by google account
     When client send a GET request to /user/1/checkin/google with:
      | user_id      | USER ID      |
      | access_token | ACCESS TOKEN |
     Then the response status should be "400"
      And the JSON response should include error code: "002"
      And the JSON response should include description: "not binding yet"

  Scenario: [REST_01_08_05]
    Client sign in by google uuid and access token and already has a portal account
    Given client has registered in Rest API by google account
      And this account is already binding to "google_oauth2"
      And client already has a portal account
     When client send a GET request to /user/1/checkin/google with:
      | user_id      | USER ID      |
      | access_token | ACCESS TOKEN |
     Then the response status should be "400"
      And the JSON response should include error code: "003"
      And the JSON response should include description: "not have password"
