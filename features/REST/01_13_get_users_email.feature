Feature: [REST_01_13] Get User's Email

  Background:
    Given a signed in client
      And an existing certificate and RSA key

  Scenario Outline: [REST_13_01]
    device try to query user’s email by cloud_ids
    Given a device has <record_count> emails including <valid> cloud_id and some <invalid> cloud_id with:
     When device request GET to /user/1/email with:
      | cloud_ids            | ENCODED USER ID              |
      | certificate_serial   | SERIAL_NAME                  |
      | signature            | SIGNATURE                    |
     Then the response status should be "200"
      And the JSON response at "emails" size should be equal to valid cloud_id number
      And the JSON response at "ids_not_found" size should be equal to invalid cloud_id number
    Examples:
      | record_count | valid | invalid |
      | 0            |  0    |  0      |
      | 1            |  1    |  0      |
      | 5            |  2    |  3      |

  Scenario: [REST_13_02]
    client try to logout from APP with invalid signature
     When device request GET to /user/1/email with:
      | cloud_ids            | ENCODED USER IDs      |
      | certificate_serial   | SERIAL_NAME           |
      | signature            | INVALID SIGNATURE     |
     Then the response status should be "400"
      And the JSON response should include error code: "101"
      And the JSON response should include description: "Invalid signature"
