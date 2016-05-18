Feature: [REST_01_05] Modify Email Address

  Scenario: [REST_01_05_01]
    modify email account with valid authentication token
    Given a signed in client
      And client has not confirmed
     When client send a PUT request to /user/1/email with:
      | email                | new@ecoworkinc.com           |
      | cloud_id             | VALID_CLOUD_ID               |
      | authentication_token | VALID AUTHENTICATION TOKEN   |
     Then the response status should be "200"
      And the JSON response should be
      """
      {"result":"success"}
      """
      And Email deliveries should be 1

  Scenario: [REST_01_05_02]
    modify email account with wrong authentication token
    Given a signed in client
      And client has not confirmed
     When client send a PUT request to /user/1/email with:
      | email                | new@ecoworkinc.com           |
      | cloud_id             | VALID_CLOUD_ID               |
      | authentication_token | INVALID AUTHENTICATION TOKEN |
     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."
      And Email deliveries should be 0

  Scenario: [REST_01_05_03]
    modify email account with the same one
    Given a signed in client
      And client has not confirmed
     When client send a PUT request to /user/1/email with:
      | email                | THE_SAME_EMAIL               |
      | cloud_id             | VALID_CLOUD_ID               |
      | authentication_token | VALID AUTHENTICATION TOKEN   |
     Then the response status should be "400"
      And the JSON response should include error code: "003"
      And the JSON response should include description: "new E-mail is the same as old"
      And Email deliveries should be 0

  Scenario: [REST_01_05_04]
    modify email account with the email has been taken
    Given a signed in client
      And client has not confirmed
    Given an existing user with:
      | id                   | taken@ecoworkinc.com         |
      | password             | taken123                     |
     When client send a PUT request to /user/1/email with:
      | email                | taken@ecoworkinc.com         |
      | cloud_id             | VALID_CLOUD_ID               |
      | authentication_token | VALID AUTHENTICATION TOKEN   |

     Then the response status should be "400"
      And the JSON response should include error code: "002"
      And the JSON response should include description: "new E-mail has been taken"
      And Email deliveries should be 0

  Scenario Outline: [REST_01_05_05]
    modify email account with invalid email format
    Given a signed in client
      And client has not confirmed
    Given an existing user with:
      | id                   | taken@ecoworkinc.com         |
      | password             | taken123                     |
     When client send a PUT request to /user/1/email with:
      | email                | <email_format>             |
      | cloud_id             | VALID_CLOUD_ID             |
      | authentication_token | VALID AUTHENTICATION TOKEN |

     Then the response status should be "400"
      And the JSON response should include error code: "004"
      And the JSON response should include description: "invalid email"
      And Email deliveries should be 0
    Examples:
      | email_format |
      |              |
      | test         |
      | @example.com |
      | test@        |

  Scenario: [REST_01_05_06]
    modify email account with user account has been confirmed
    Given a signed in client
     When client send a PUT request to /user/1/email with:
      | email                | new@ecoworkinc.com           |
      | cloud_id             | VALID_CLOUD_ID               |
      | authentication_token | VALID AUTHENTICATION TOKEN   |
     Then the response status should be "400"
      And the JSON response should include error code: "006"
      And the JSON response should include description: "the user has been confirmed"
      And Email deliveries should be 0

  Scenario: [REST_01_05_07]
    modify email account with valid access token

    Given a signed in client
      And client has not confirmed
     When client send a PUT request to /user/1/email with:
      | email                | new@ecoworkinc.com           |
      | cloud_id             | VALID_CLOUD_ID               |
      | authentication_token | VALID ACCESS TOKEN           |
     Then the response status should be "200"
      And the JSON response should be
      """
      {"result":"success"}
      """
      And Email deliveries should be 1

  Scenario: [REST_01_05_08]
    modify email account with revoked access token
    Given a signed in client
      And client has not confirmed
     When client send a PUT request to /user/1/email with:
      | email                | new@ecoworkinc.com           |
      | cloud_id             | VALID_CLOUD_ID               |
      | authentication_token | REVOKED ACCESS TOKEN         |
     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."
      And Email deliveries should be 0

  Scenario: [REST_01_05_09]
    modify email account with expired access token
    Given a signed in client
      And client has not confirmed
     When client send a PUT request to /user/1/email with:
      | email                | new@ecoworkinc.com           |
      | cloud_id             | VALID_CLOUD_ID               |
      | authentication_token | EXPIRED ACCESS TOKEN         |
     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."
      And Email deliveries should be 0
