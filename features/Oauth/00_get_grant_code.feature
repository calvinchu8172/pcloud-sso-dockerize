Feature: [OAUTH_00] get grant code

  Background:
    Given an oauth client user exists

  Scenario: [OAUTH_01_01]
    Valid client user get grant code

    Given client user confirmed
    And 1 existing client app and access token record
    When client send a POST request to /oauth/token with:
      | grant_type            | refresh_token                  |
      | refresh_token         | VALID REFRESH TOKEN            |
      | client_id             | VALID CLIENT ID                |
      | client_secret         | VALID CLIENT SECRET            |
      | redirect_uri          | REDIRECT URI                   |

    Then the response status should be "200"
    And the JSON response should include:
      """
      ["access_token", "token_type", "expires_in", "refresh_token", "created_at"]
      """