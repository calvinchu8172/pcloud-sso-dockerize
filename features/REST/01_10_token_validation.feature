Feature: [REST_01_10] Token Validation

  Background:
    Given a signed in client

  Scenario: [REST_01_10_01]
    Client access resources with valid authentication token
     When client send a GET request to "/user/1/token" with:
      |cloud_id             | ENCODED USER ID           |
      |authentication_token | VALID AUTHENTICATION TOKEN|
     Then the response status should be "200"
      And the JSON response should be
      """
      {"result":"valid",
       "timeout":21600}
      """

  Scenario: [REST_01_10_02]
    Client access resource with expired authentication token
     When client send a GET request to "/user/1/token" with:
      |cloud_id             | ENCODED USER ID             |
      |authentication_token | INVALID AUTHENTICATION TOKEN|
     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."

  Scenario: [REST_01_10_03]
    Client access resource with invalid cloud id
     When client send a GET request to "/user/1/token" with:
      |cloud_id             | INVALID ENCODED USER ID     |
      |authentication_token | VALID AUTHENTICATION TOKEN|
     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."

  Scenario: [REST_01_10_04]
    Client access resources with valid access token
     When client send a GET request to "/user/1/token" with:
      |cloud_id             | ENCODED USER ID           |
      |authentication_token | VALID ACCESS TOKEN        |
     Then the response status should be "200"
      And the JSON response should be
      """
      {"result":"valid",
       "timeout":21600}
      """

  Scenario: [REST_01_10_05]
    Client access resource with revoked access token
     When client send a GET request to "/user/1/token" with:
      |cloud_id             | ENCODED USER ID             |
      |authentication_token | REVOKED ACCESS TOKEN        |
     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."

  Scenario: [REST_01_10_06]
    Client access resource with expired access token
     When client send a GET request to "/user/1/token" with:
      |cloud_id             | ENCODED USER ID             |
      |authentication_token | EXPIRED ACCESS TOKEN        |
     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."
