Feature: [REST_01_12] Log out from RESTful API

  Background:
    Given a signed in client

  Scenario: [REST_12_01]
    client try to log out with valid clout id and account token
     When client send a DELETE request to /user/1/token with:
      | cloud_id      | ENCODED USER ID |
      | account_token | ACCOUNT_TOKEN   |
     Then the response status should be "200"
      And the JSON response should be
      """
      {"result":"success"}
      """

  Scenario: [REST_12_02]
    client try to sign in again with invalid cloud_id
     When client send a DELETE request to /user/1/token with:
      | cloud_id      | INVALID ENCODED USER ID |
      | account_token | ACCOUNT TOKEN   |
     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."

  Scenario: [REST_12_03]
    client try to sign in again with invalid account token
     When client send a DELETE request to /user/1/token with:
      | cloud_id      | ENCODED USER ID |
      | account_token | INVALID ACCOUNT TOKEN   |
     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."
