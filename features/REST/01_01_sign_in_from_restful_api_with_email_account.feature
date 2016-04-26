Feature: [REST_01_01] Sign in from RESTful API with E-mail account

  Scenario: [REST_01_01_01]
    User sign in from NAS
    Given an existing certificate and RSA key
    Given an existing user's account and password
     When client send a POST request to /user/1/token with:
      | id       | acceptance@ecoworkinc.com |
      | password | secret123                 |
     Then the response status should be "200"
      And the JSON response should include:
      """
      ["user_id", "account_token", "authentication_token", "timeout", "confirmed", "registered_at", "bot_list", "stun_ip_addresses", "xmpp_account", "xmpp_ip_addresses"]
      """

  Scenario Outline: [REST_01_01_02]
    User sign in from APP
    Given an existing certificate and RSA key
    Given an existing user's account and password
     When client send a POST request to /user/1/token with:
      | id       | acceptance@ecoworkinc.com   |
      | password | secret123                   |
      | app_key  | mobile_app_notification_key |
      | os       | <os_version>                |
     Then the response status should be "200"
      And the JSON response should include:
      """
      ["user_id", "account_token", "authentication_token", "timeout", "confirmed", "registered_at", "bot_list", "stun_ip_addresses", "xmpp_account", "xmpp_ip_addresses"]
      """
      And the client should be using <os_name>
      And the client's mobile app key should be "mobile_app_notification_key"
    Examples:
      | os_version | os_name |
      | 0          | other   |
      | 1          | iOS     |
      | 2          |   Android |

  Scenario: [REST_01_01_03]
    User sign in with wrong password
    Given an existing certificate and RSA key
    Given an existing user's account and password
     When client send a POST request to /user/1/token with:
      | id       | acceptance@ecoworkinc.com |
      | password | secret369                 |
     Then the response status should be "400"
      And the JSON response should include error code: "001"
      And the JSON response should include description: "Invalid email or password."

  Scenario: [REST_01_01_04]
    User sign in with the E-mail account have not confirmed yet longer than 3 days
    Given an existing certificate and RSA key
    Given an existing user's account and password but have not confirmed yet longer than 3 days
     When client send a POST request to /user/1/token with:
      | id       | acceptance@ecoworkinc.com |
      | password | secret123                 |
     Then the response status should be "400"
      And the JSON response should include error code: "002"
      And the JSON response should include description: "client have to confirm email account before continuing."

  Scenario: [REST_01_01_05]
    User sign in with different uuid will get the different xmapp accounts
    Given an existing certificate and RSA key
      And an existing user's account and password
     When client send a POST request to /user/1/token with:
      | id       | acceptance@ecoworkinc.com |
      | password | secret123                 |
      | uuid     | test_a                    |
      And record the first xmpp account
     When client send a POST request to /user/1/token with:
      | id       | acceptance@ecoworkinc.com |
      | password | secret123                 |
      | uuid     | test_b                    |
     Then the second xmpp account is different with the first one
