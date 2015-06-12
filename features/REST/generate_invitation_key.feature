Feature: Generate Invitation Key

  Background:
    Given a signed in client
    And an existing device with pairing signed in client

  Scenario: [REST_03_01]
    Client invite user with valid information

    When client send a POST request to "/resource/1/invitation" with:
      | cloud_id | ENCODE USER ID |
      | device_id | ENCODE DEVICE ID |
      | share_point | SHARE POINT |
      | expire_count | 5 |
      | permission | 1 |
      | authentication_token | AUTHENTICATION_TOKEN |

    Then the response status should be "200"
    And the JSON response should include valid invitation_key

  Scenario: [REST_03_02]
    Client invite user with invalid device id

    When client send a POST request to "/resource/1/invitation" with:
      | cloud_id | ENCODE USER ID |
      | device_id | INVALID ENCODE DEVICE ID |
      | share_point | SHARE POINT |
      | expire_count | 5 |
      | permission | 1 |
      | authentication_token | AUTHENTICATION_TOKEN |

    Then the response status should be "400"
    And the JSON response should include error code: "004"
    And the JSON response should include description: "Invalid device."

  Scenario: [REST_03_03]
    Client invite user with invalid permission

    When client send a POST request to "/resource/1/invitation" with:
      | cloud_id | ENCODE USER ID |
      | device_id | ENCODE DEVICE ID |
      | share_point | SHARE POINT |
      | expire_count | 5 |
      | permission | 4 |
      | authentication_token | AUTHENTICATION_TOKEN |

    Then the response status should be "400"
    And the JSON response should include error code: "005"
    And the JSON response should include description: "Invalid share point or permission."


  Scenario: [REST_03_04]
    Client invite user with expired authentication token

    When client send a POST request to "/resource/1/invitation" with:
      | cloud_id | ENCODE USER ID |
      | device_id | ENCODE DEVICE ID |
      | share_point | SHARE POINT |
      | expire_count | 5 |
      | permission | 1 |
      | authentication_token | EXPIRED AUTHENTICATION_TOKEN |

    Then the response status should be "400"
    And the JSON response should include error code: "012"
    And the JSON response should include description: "Invalid cloud id or token."
