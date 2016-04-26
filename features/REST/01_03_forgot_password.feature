Feature: [REST_01_03] Forgot Password

  Background:
    Given an existing user with:
      | id       | example@ecoworkinc.com |
      | password | password123            |

  Scenario: [REST_01_03_01]
    Client reset password with registered E-mail
     When client send a POST request to /user/1/password with:
      |email| example@ecoworkinc.com|
     Then the response status should be "200"
      And the JSON response should be
      """
      {"result":"success"}
      """
      And Email deliveries should be 1

  Scenario: [REST_01_03_02]
    Client reset password with unregistered E-mail
     When client send a POST request to /user/1/password with:
      |email| invalid@ecoworkinc.com|
     Then the response status should be "400"
      And the JSON response should include error code: "001"
      And the JSON response should include description: "E-mail not found."
      And Email deliveries should be 0
