Feature: [REST_05] Request User's Device List API Testing

  Background:
    Given a signed in client

  Scenario Outline: [REST_05_01]
    request user device list with valid authentication token
    Given a user try to request own device list with <record_count> devices including <own> device and <other> device from APP
    When client send a GET request to "/resource/1/device_list" with:
      | cloud_id             | ENCODE USER ID               |
      | authentication_token | VALID AUTHENTICATION TOKEN   |
    Then the response status should be "200"
    And the JSON response should include
      """
      ["xmpp_account", "mac_address", "host_name", "wan_ip", "firmware_ver", "last_update_time", "is_owner"]
      """
    Examples:
      | record_count | own | other|
      | 0            |  0  |  0   |
      | 1            |  1  |  0   |
      | 5            |  2  |  3   |

  Scenario: [REST_05_02]
    request user device list with expired authentication token
    # Given a user try to request own device list with 1 devices from APP
    Given a user try to request own device list with 1 devices including 1 device and 0 device from APP
     When client send a GET request to "/resource/1/device_list" with:
      | cloud_id             | ENCODE USER ID                |
      | authentication_token | EXPIRED AUTHENTICATION TOKEN  |
     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."

  Scenario Outline: [REST_05_03]
    request user device list with valid access token
    Given a user try to request own device list with <record_count> devices including <own> device and <other> device from APP
     When client send a GET request to "/resource/1/device_list" with:
      | cloud_id             | ENCODE USER ID               |
      | authentication_token | VALID ACCESS TOKEN           |
     Then the response status should be "200"
      And the JSON response should include
      """
      ["xmpp_account", "mac_address", "host_name", "wan_ip", "firmware_ver", "last_update_time", "is_owner"]
      """
     Examples:
      | record_count | own | other|
      | 0            |  0  |  0   |
      | 1            |  1  |  0   |
      | 5            |  2  |  3   |

  Scenario: [REST_05_04]
    request user device list with revoked access token
    # Given a user try to request own device list with 1 devices from APP
    Given a user try to request own device list with 1 devices including 1 device and 0 device from APP
     When client send a GET request to "/resource/1/device_list" with:
      | cloud_id             | ENCODE USER ID                |
      | authentication_token | REVOKED ACCESS TOKEN          |
     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."

  Scenario: [REST_05_05]
    request user device list with expired access token
    # Given a user try to request own device list with 1 devices from APP
    Given a user try to request own device list with 1 devices including 1 device and 0 device from APP
     When client send a GET request to "/resource/1/device_list" with:
      | cloud_id             | ENCODE USER ID                |
      | authentication_token | EXPIRED ACCESS TOKEN          |
     Then the response status should be "400"
      And the JSON response should include error code: "201"
      And the JSON response should include description: "Invalid cloud id or token."
