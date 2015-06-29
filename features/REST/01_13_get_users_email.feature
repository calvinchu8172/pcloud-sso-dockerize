Feature: Get User's Email

  Background:
    Given a signed in client
    And an existing certificate and RSA key

  Scenario: [REST_13_01]
    device try to query user’s email by cloud_ids

    Given a device has 3 valid cloud_id and 2 invalid cloud_id with:
      | cloud_id1           | ENCODE USER ID 1           |
      | cloud_id2           | ENCODE USER ID 2           |
      | cloud_id3           | ENCODE USER ID 3           |
      | cloud_id4           | INVALID ENCODE USER ID 4   |
      | cloud_id5           | INVALID ENCODE USER ID 5   |
    When device request GET to /user/1/email with:
      | cloud_ids            | ENCODED USER ID              |
      | certificate_serial   | SERIAL_NAME                  |
      | signature            | SIGNATURE                    |
    Then the response status should be "200"
    And the JSON response at "emails" size should be 3
    And the JSON response at "ids_not_found" size should be 2

  Scenario: [REST_13_02]
    client try to logout from APP with invalid signature

    When device request GET to /user/1/email with:
      | cloud_ids            | ENCODED USER IDs      |
      | certificate_serial   | SERIAL_NAME           |
      | signature            | INVALID SIGNATURE     |
    Then the response status should be "400"
    And the JSON response should include error code: "101"
    And the JSON response should include description: "Invalid signature"

