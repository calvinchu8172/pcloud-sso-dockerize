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
      ["id", "account_token", "authentication_token", "timeout", "confirmed", "registered_at", "bot_list", "xmpp_ip_addresses", "stun_ip_addresses", "xmpp_account"]
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

  @timecop
  Scenario: [OAUTH_02_03]
   Valid client user get user information with valid refresh token
   
   Given Time now is "2017-01-01 00:00:00"
   Given client user confirmed
   And 1 existing client app and access token record
   When client send a GET request to /api/v1/my/info with:
     | access_token         | VALID ACCESS TOKEN            |
   Then the response status should be "200"
   And the JSON response should include:
     """
     ["id", "account_token", "authentication_token", "timeout", "confirmed", "registered_at", "bot_list", "xmpp_ip_addresses", "stun_ip_addresses", "xmpp_account"]
     """
    Given "30" days later
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
    When client send a GET request to /api/v1/my/info with:
     | access_token         | VALID ACCESS TOKEN            |
    Given "366" days later
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
    When client send a GET request to /api/v1/my/info with:
     | access_token         | VALID ACCESS TOKEN            |