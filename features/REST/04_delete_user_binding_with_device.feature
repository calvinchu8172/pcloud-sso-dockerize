Feature: [REST_04] Delete User's Binding with Device

  Background:
    Given a signed in client
      And an existing device with pairing signed in client
      And 1 existing invitation record
      And an existing certificate and RSA key

  Scenario: [REST_04_01]
    Client try to delete user's binding on portal with valid information
     When client send a DELETE request to /resource/1/permission with:
      | device_account     | DEVICE XMPP ACCOUNT |
      | cloud_id           | ENCODED USER ID     |
      | certificate_serial | CERTIFICATE SERIAL  |
      | signature          | SIGNATURE           |
     Then the response status should be "200"
      And the JSON response should be
      """
      {"result":"success"}
      """
      And permission record count should be 0

  Scenario: [REST_04_02]
    Client try to delete user's binding on portal with invalid device account
     When client send a DELETE request to /resource/1/permission with:
      | device_account     | INVALID DEVICE ACCOUNT |
      | cloud_id           | ENCODED USER ID        |
      | certificate_serial | CERTIFICATE SERIAL     |
      | signature          | SIGNATURE              |
     Then the response status should be "400"
      And the JSON response should include error code: "004"
      And the JSON response should include description: "Invalid device."
      And permission record count should be 1

  Scenario: [REST_04_03]
    Client try to delete user's binding on portal with invalid cloud id
     When client send a DELETE request to /resource/1/permission with:
      | device_account     | DEVICE ACCOUNT |
      | cloud_id           | INVALID ENCODED USER ID        |
      | certificate_serial | CERTIFICATE SERIAL     |
      | signature          | SIGNATURE              |
     Then the response status should be "400"
      And the JSON response should include error code: "012"
      And the JSON response should include description: "Invalid cloud id."
      And permission record count should be 1

  Scenario: [REST_04_04]
    Client try to delete user's binding on portal with invalid certificate serial
     When client send a DELETE request to /resource/1/permission with:
      | device_account     | DEVICE ACCOUNT |
      | cloud_id           | ENCODED USER ID        |
      | certificate_serial | INVALID CERTIFICATE SERIAL     |
      | signature          | SIGNATURE              |
     Then the response status should be "400"
      And the JSON response should include error code: "013"
      And the JSON response should include description: "Invalid certificate_serial."
      And permission record count should be 1

  Scenario: [REST_04_05]
    Client try to delete user's binding on portal with invalid signature
     When client send a DELETE request to /resource/1/permission with:
      | device_account     | DEVICE ACCOUNT |
      | cloud_id           | ENCODED USER ID        |
      | certificate_serial | CERTIFICATE SERIAL     |
      | signature          | INVALID SIGNATURE              |
     Then the response status should be "400"
      And the JSON response should include error code: "101"
      And the JSON response should include description: "Invalid signature."
      And permission record count should be 1
