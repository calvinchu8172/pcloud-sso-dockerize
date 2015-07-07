Feature: Token Validation

  Background:
    Given a signed in client

  Scenario: [REST_01_10_01]
    Client access resources with valid authentication token

    When client send a GET request to /user/1/token with:
      |cloud_id | ENCODED USER ID|
      |authentication_token | VALID AUTHENTICATION TOKEN|

    Then the response status should be "200"
    And the JSON response should be
      """
      {"result":"valid",
       "timeout":3600}
      """

  Scenario: [REST_01_10_02]
    Client access resource with expired authentication token

    When client send a GET request to /user/1/token with:
      |cloud_id | ENCODED USER ID|
      |authentication_token | INVALID AUTHENTICATION TOKEN|

    Then the response status should be "400"
    And the JSON response should include error code: "201"
    And the JSON response should include description: "Invalid cloud id or token."

