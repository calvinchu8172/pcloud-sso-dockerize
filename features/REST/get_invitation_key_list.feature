Feature: Get Invitation Key List

  Background:
    Given a signed in client
    And an existing device with pairing signed in client
    And an existing invitation record

  Scenario: [REST_02_01]
    Client access invitaiton list with valid authentication token

  When client send a GET request to "/resource/1/invitation" with:
    | cloud_id             | ENCODE USER ID         |
    | last_updated_at      | LAST UPDATED TIMESTAMP |
    | authentication_token | AUTHENTICATION_TOKEN   |

  Then the response status should be "200"
  And the JSON response should include multiple:
    """
    ["invitation_key", "device_id", "share_point", "permission", "accepted_user"]
    """

  Scenario: [REST_02_02]
    Client access invitation list with expired authentication token

  When client send a GET request to "/resource/1/invitation" with:
    | cloud_id             | ENCODE USER ID               |
    | last_updated_at      | LAST UPDATED TIMESTAMP       |
    | authentication_token | EXPIRED_AUTHENTICATION_TOKEN |

  Then the response status should be "400"
  And the JSON response should include error code: "201"
  And the JSON response should include description: "Invalid cloud id or token."

  Scenario: [REST_02_03]
    Client access invitation list with invalid cloud_id

  When client send a GET request to "/resource/1/invitation" with:
    | cloud_id             | INVALID ENCODE USER ID       |
    | last_updated_at      | LAST UPDATED TIMESTAMP       |
    | authentication_token | AUTHENTICATION_TOKEN |

  Then the response status should be "400"
  And the JSON response should include error code: "201"
  And the JSON response should include description: "Invalid cloud id or token."
