Feature: Request User's Device List API Testing

  Background:
    Given a user sign in from APP

  Scenario: [REST_05_01]
    request user device list with valid authentication token

    Given a user try to request own device list from APP
    When APP sent a GET request to "/resource/1/device_list" with:
      | cloud_id             | ENCODE USER ID         |
      | authentication_token | AUTHENTICATION_TOKEN   |
    Then the HTTP response status should be "200"
    And the JSON response should include
      """
      ["xmpp_account","mac_address","host_name","wan_ip","firmware_ver","last_update_time", "is_owner"]
      """

  Scenario: [REST_05_02]
    request user device list with expired authentication token

    Given a user try to request own device list from APP
    When APP sent a GET request to "/resource/1/device_list" with:
      | cloud_id             | ENCODE USER ID                 |
      | authentication_token | EXPIRED_AUTHENTICATION_TOKEN   |
    Then the HTTP response status should be "400"
    And the responsed JSON should include error code: "201"
    And the responsed JSON should include description: "Invalid cloud id or token."