Feature: [REST_02] Get Invitation Key List

  Background:
    Given a signed in client
      And an existing device with pairing signed in client

  Scenario Outline: [REST_02_01]
    Client access invitaiton list with valid authentication token and last updated time
    Given <record_count> existing invitation record
     When client send a GET request to /resource/1/invitation with:
      | cloud_id             | ENCODE USER ID               |
      | last_updated_at      | LAST UPDATED TIMESTAMP       |
      | authentication_token | VALID AUTHENTICATION TOKEN   |
    Then the response status should be "200"
     And the JSON response should include <record_count>:
      """
      ["invitation_key", "device_id", "share_point", "permission", "accepted_user"]
      """
    Examples:
      | record_count |
      | 0            |
      | 1            |
      | 5            |

  Scenario: [REST_02_02]
    Client access invitaiton list with valid authentication token and expired last updated time
    Given 1 existing invitation record
     When client send a GET request to /resource/1/invitation with:
      | cloud_id             | ENCODE USER ID                 |
      | last_updated_at      | EXPIRED LAST UPDATED TIMESTAMP |
      | authentication_token | VALID AUTHENTICATION TOKEN     |
    Then the response status should be "200"
     And the JSON response should be empty

  Scenario: [REST_02_03]
    Client access invitation list with expired authentication token
    Given 1 existing invitation record
     When client send a GET request to /resource/1/invitation with:
      | cloud_id             | ENCODE USER ID               |
      | last_updated_at      | LAST UPDATED TIMESTAMP       |
      | authentication_token | EXPIRED AUTHENTICATION TOKEN |
    Then the response status should be "400"
     And the JSON response should include error code: "201"
     And the JSON response should include description: "Invalid cloud id or token."

  Scenario: [REST_02_04]
    Client access invitation list with invalid cloud_id
    Given 1 existing invitation record
     When client send a GET request to /resource/1/invitation with:
      | cloud_id             | INVALID ENCODE USER ID       |
      | last_updated_at      | LAST UPDATED TIMESTAMP       |
      | authentication_token | VALID AUTHENTICATION TOKEN   |
    Then the response status should be "400"
     And the JSON response should include error code: "201"
     And the JSON response should include description: "Invalid cloud id or token."


  Scenario Outline: [REST_02_05]
    Client access invitaiton list with valid access token and last updated time
    Given <record_count> existing invitation record
     When client send a GET request to /resource/1/invitation with:
      | cloud_id             | ENCODE USER ID               |
      | last_updated_at      | LAST UPDATED TIMESTAMP       |
      | authentication_token | VALID ACCESS TOKEN           |
    Then the response status should be "200"
     And the JSON response should include <record_count>:
      """
      ["invitation_key", "device_id", "share_point", "permission", "accepted_user"]
      """
    Examples:
      | record_count |
      | 0            |
      | 1            |
      | 5            |

  Scenario: [REST_02_06]
    Client access invitation list with revoked access token
    Given 1 existing invitation record
     When client send a GET request to /resource/1/invitation with:
      | cloud_id             | ENCODE USER ID              |
      | last_updated_at      | LAST UPDATED TIMESTAMP      |
      | authentication_token | REVOKED ACCESS TOKEN        |
    Then the response status should be "400"
     And the JSON response should include error code: "201"
     And the JSON response should include description: "Invalid cloud id or token."

  Scenario: [REST_02_07]
    Client access invitation list with expired access token
    Given 1 existing invitation record
     When client send a GET request to /resource/1/invitation with:
      | cloud_id             | ENCODE USER ID              |
      | last_updated_at      | LAST UPDATED TIMESTAMP      |
      | authentication_token | EXPIRED ACCESS TOKEN        |
    Then the response status should be "400"
     And the JSON response should include error code: "201"
     And the JSON response should include description: "Invalid cloud id or token."
