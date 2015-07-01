Feature: Google Register

  Background:

    Given the client has access token and uuid from google
    And an existing certificate and RSA key

  Scenario:
    Client register by google uuid and access token

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

  Scenario:
    Client register by invalid google uuid and access token

    When client send a POST request to /user/1/register/google with:
    | user_id      | INVALID USER ID      |
    | access_token | INVALID ACCESS TOKEN |
    | password     | test_password        |
    | signature    | SIGNATURE            |

    Then the response status should be "400"
    And the JSON response should include error code: "001"
    And the JSON response should include description: "Invalid Google account"

  Scenario Outline:
    Client register by google uuid and access token with invalid password

    When client send a POST request to /user/1/register/google with:
    | user_id      | USER ID      |
    | access_token | ACCESS TOKEN |
    | password     | <password>   |
    | signature    | SIGNATURE    |

    Then the response status should be "400"
    And the JSON response should include error code: "002"
    And the JSON response should include description: "Password has to be 8-14 characters length"

    Examples:
    | password        |
    | 123             |
    | 123456789012345 |

  Scenario:
    Client register by google uuid and access token but already registered

    Given client has registered in Rest API by google account
    And this account is already binding to "google_oauth2"

    When client send a POST request to /user/1/register/google with:
    | user_id      | USER ID       |
    | access_token | ACCESS TOKEN  |
    | password     | test_password |
    | signature    | SIGNATURE     |

    Then the response status should be "400"
    And the JSON response should include error code: "003"
    And the JSON response should include description: "registered account"

  Scenario:
    Client register by google uuid and access token, already registered but password invalid

    Given client has registered in Rest API by google account

    When client send a POST request to /user/1/register/google with:
    | user_id      | USER ID      |
    | access_token | ACCESS TOKEN |
    | password     | another_pw   |
    | signature    | SIGNATURE    |

    Then the response status should be "400"
    And the JSON response should include error code: "004"
    And the JSON response should include description: "Invalid email or password."

  Scenario:
    Client register by google uuid and access token with invalid signature

    When client send a POST request to /user/1/register/google with:
    | user_id      | USER ID           |
    | access_token | ACCESS TOKEN      |
    | password     | test_password     |
    | signature    | INVALID SIGNATURE |

    Then the response status should be "400"
    And the JSON response should include error code: "101"
    And the JSON response should include description: "Invalid signature"


