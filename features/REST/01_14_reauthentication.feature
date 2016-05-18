Feature: [REST_01_14] reauthentication

  Background:
    Given a signed in client

  Scenario: [REST_14_01]
    client try to sign in again with account token
     When client send a PUT request to /user/1/token with:
      | cloud_id      | ENCODED USER ID |
      | account_token | ACCOUNT_TOKEN   |
     Then the response status should be "200"
      And the JSON response should not be the same with:
      """
      { "authentication_token": "AUTHENTICATIONTOEKNSTRING" }
      """

  Scenario: [REST_14_02]
    client try to sign in again with invalid account token
     When client send a PUT request to /user/1/token with:
      | cloud_id      | ENCODED USER ID |
      | account_token | INVALID ACCOUNT TOKEN   |
     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."
