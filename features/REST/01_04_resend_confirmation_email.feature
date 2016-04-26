Feature: [REST_01_04] Resend Confirmation E-mail

  Scenario: [REST_01_04_01]
    resend confirmation email
    Given an existing user with:
      | id       | example@ecoworkinc.com |
      | password | password123            |
     When client send a POST request to /user/1/confirmation
     Then the response status should be "200"
      And the JSON response should be
      """
      {"result":"success"}
      """
      And Email deliveries should be 1

  Scenario: [REST_01_04_01]
    resend confirmation email with unregistered email
     When client send a POST request to /user/1/confirmation
     Then the response status should be "400"
      And the JSON response should include error code: "001"
      And the JSON response should include description: "E-mail not found"
      And Email deliveries should be 0
