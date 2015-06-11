Feature: Generate Invitation Key

  Background:
    Given a signed in client
    And an existing device with pairing signed in client

  Scenario: [REST_03_01]
    Client invite user with valid information

    When client send a POST request to "/resource/1/invitation" with:
      | cloud_id | device_id | share_point | expire_count | permission | authentication_token |
      | encode_cloud_id| encode_device_id | share_point | 5 | 1 | AUTHENTICATION_TOKEN |

    Then the response status should be "200"
    And the JSON response should be:
      """
      [{"invitation":"INVITATION_KEY"}]
      """

  Scenario: [REST_03_02]
    Client invite user with invalid device id

    When client send a POST request to "/resource/1/invitation" with:
      | cloud_id | device_id | share_point | expire_count | permission | authentication_token |
      | encode_cloud_id| encode_device_id | share_point | 5 | 1 | AUTHENTICATION_TOKEN |

    Then the response status should be "400"
    And the JSON response should be:
      """
      [{"error_code":"004"}, {"description":"Invalid device."}]
      """

  Scenario: [REST_03_03]
    Client invite user with invalid permission

  Scenario: [REST_03_04]
    Client invite user with expired authentication token