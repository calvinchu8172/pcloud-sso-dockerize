Feature: [REST_01_02] Register with E-mail account

  Background:
    Given an existing certificate and RSA key

  Scenario: [REST_01_02_01]
    register
     When client send a POST request to /user/1/register with:
      | id              | acceptance@ecoworkinc.com    |
      | password        | secret123                    |
      | signature       | VALID SIGNATURE              |
      | Accept-Language | fr                           |
     Then the response status should be "200"
      And the JSON response should include:
      """
      ["user_id", "account_token", "authentication_token", "timeout", "confirmed", "registered_at", "bot_list", "stun_ip_addresses", "xmpp_account", "xmpp_ip_addresses"]
      """
      And Email deliveries should be 1
      And Portal's language should be changed to "fr"

  Scenario: [REST_01_02_02]
    register with email has been taken
    Given an existing user with:
      | id        | taken@ecoworkinc.com         |
      | password  | taken123                     |
     When client send a POST request to /user/1/register with:
      | id        | taken@ecoworkinc.com         |
      | password  | taken123                     |
      | signature | VALID SIGNATURE              |
     Then the response status should be "400"
      And the JSON response should include error code: "001"
      And the JSON response should include description: "emailhas already been taken"
      And Email deliveries should be 0

  Scenario: [REST_01_02_03]
    register with a password too long
     When client send a POST request to /user/1/register with:
      | id        | longpassword@ecoworkinc.com  |
      | password  | longpassword123              |
      | signature | VALID SIGNATURE              |
     Then the response status should be "400"
      And the JSON response should include error code: "002"
      And the JSON response should include description: "passwordis too long (maximum is 14 characters)"
      And Email deliveries should be 0

  Scenario: [REST_01_02_04]
    register with a password too short
     When client send a POST request to /user/1/register with:
      | id        | shortpassword@ecoworkinc.com |
      | password  | srt                          |
      | signature | VALID SIGNATURE              |
     Then the response status should be "400"
      And the JSON response should include error code: "002"
      And the JSON response should include description: "passwordis too short (minimum is 8 characters)"
      And Email deliveries should be 0

  Scenario: [REST_01_02_05]
    register with a invalid signature
     When client send a POST request to /user/1/register with:
      | id        | acceptance@ecoworkinc.com    |
      | password  | secret123                    |
      | signature | INVALID SIGNATURE            |
     Then the response status should be "400"
      And the JSON response should include error code: "101"
      And the JSON response should include description: "Invalid signature"
      And Email deliveries should be 0
