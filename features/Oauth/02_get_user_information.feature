Feature: [OAUTH_02] get user informaiton

  Background:
    Given an oauth client user exists

  Scenario: [OAUTH_02_01]
    Valid client user get user information with valid access token

    Given client user confirmed
    And 1 existing client app and access token record
    When client send a GET request to /api/v1/my/info with:
      | access_token         | VALID ACCESS TOKEN            |

    Then the response status should be "200"
    And the JSON response should include:
      """
      ["user_id", "account_token", "authentication_token", "timeout", "confirmed"]
      """

  Scenario: [OAUTH_02_02]
    Valid client user get user information with invalid access token

    Given client user confirmed
    And 1 existing client app and access token record
    When client send a GET request to /api/v1/my/info with:
      | access_token         | INVALID ACCESS TOKEN            |

    Then the response status should be "401"
    And the JSON response should include error:
      """
      ["error", "invalid_token", "error_description", "The access token is invalid"]
      """