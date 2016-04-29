Feature: [REST_03] Generate Invitation Key

  Background:
    Given a signed in client
      And an existing device with pairing signed in client

  Scenario Outline: [REST_03_01]
    Client invite user with valid information and valid authentication token
     When client send a POST request to /resource/1/invitation with:
      | cloud_id             | ENCODE USER ID             |
      | device_id            | ENCODE DEVICE ID           |
      | share_point          | SHARE POINT                |
      | expire_count         | 5                          |
      | permission           | <permission>               |
      | authentication_token | VALID AUTHENTICATION TOKEN |
     Then the response status should be "200"
      And the JSON response should include valid invitation_key
     Examples:
      | permission |
      | 1          |
      | 2          |

  Scenario: [REST_03_02]
    Client invite user with invalid device id
     When client send a POST request to /resource/1/invitation with:
      | cloud_id             | ENCODE USER ID                 |
      | device_id            | INVALID ENCODE DEVICE ID       |
      | share_point          | SHARE POINT                    |
      | expire_count         | 5                              |
      | permission           | 1                              |
      | authentication_token | VALID AUTHENTICATION TOKEN     |
     Then the response status should be "400"
      And the JSON response should include error code: "004"
      And the JSON response should include description: "Invalid device."

  Scenario: [REST_03_03]
    Client invite user with invalid permission
     When client send a POST request to /resource/1/invitation with:
      | cloud_id             | ENCODE USER ID             |
      | device_id            | ENCODE DEVICE ID           |
      | share_point          | SHARE POINT                |
      | expire_count         | 5                          |
      | permission           | 4                          |
      | authentication_token | VALID AUTHENTICATION TOKEN |
     Then the response status should be "400"
      And the JSON response should include error code: "005"
      And the JSON response should include description: "Invalid share point or permission."

  Scenario: [REST_03_04]
    Client invite user with expired authentication token
     When client send a POST request to /resource/1/invitation with:
      | cloud_id             | ENCODE USER ID               |
      | device_id            | ENCODE DEVICE ID             |
      | share_point          | SHARE POINT                  |
      | expire_count         | 5                            |
      | permission           | 1                            |
      | authentication_token | EXPIRED AUTHENTICATION TOKEN |

     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."

  Scenario: [REST_03_05]
    Client invite user with invalid sharename (utf8mb4)
     When client send a POST request to /resource/1/invitation with:
      | cloud_id             | ENCODE USER ID               |
      | device_id            | ENCODE DEVICE ID             |
      | share_point          | INVALID SHARE POINT          |
      | expire_count         | 5                            |
      | permission           | 1                            |
      | authentication_token | VALID AUTHENTICATION TOKEN   |
     Then the response status should be "400"
      And the JSON response should include error code: "019"
      And the JSON response should include description: "Invalid sharename."

  Scenario Outline: [REST_03_06]
    Client invite user with valid information and valid access token
     When client send a POST request to /resource/1/invitation with:
      | cloud_id             | ENCODE USER ID       |
      | device_id            | ENCODE DEVICE ID     |
      | share_point          | SHARE POINT          |
      | expire_count         | 5                    |
      | permission           | <permission>         |
      | authentication_token | VALID ACCESS TOKEN   |
     Then the response status should be "200"
      And the JSON response should include valid invitation_key
     Examples:
      | permission |
      | 1          |
      | 2          |

  Scenario: [REST_03_07]
    Client invite user with revoked access token
     When client send a POST request to /resource/1/invitation with:
      | cloud_id             | ENCODE USER ID               |
      | device_id            | ENCODE DEVICE ID             |
      | share_point          | SHARE POINT                  |
      | expire_count         | 5                            |
      | permission           | 1                            |
      | authentication_token | REVOKED ACCESS TOKEN         |
     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."

  Scenario: [REST_03_08]
    Client invite user with expired access token
     When client send a POST request to /resource/1/invitation with:
      | cloud_id             | ENCODE USER ID               |
      | device_id            | ENCODE DEVICE ID             |
      | share_point          | SHARE POINT                  |
      | expire_count         | 5                            |
      | permission           | 1                            |
      | authentication_token | EXPIRED ACCESS TOKEN         |
     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."
