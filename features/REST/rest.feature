Feature: REST API testing

  Background:
    Given the device with information
      | mac_address      | 099789665701 |
      | serial_number    | A123456      |
      | model_name       | NSA325       |
      | firmware_version | 1.0          |
      | algo             | 1            |

  Scenario Outline: [REST-00-01]
    Check correct update process when valid format

    When the device already registration
    And the device "<information>" was be changed to "<value>"
    And the device send information to REST API
    Then the API should return success respond
    And the record in databases as expected

    Examples: Valid format
      | information      | value        |
      | firmware_version | 2.0          |
      | mac_address      | 000000000000 |
      | serial_number    | 654321A      |

  Scenario Outline: [REST-00-02]
    Check incorrect update process when invalid format

    Given the device already registration
    And the device "<information>" was be changed to "<value>"
    And the device send information to REST API
    Then the API should return "<http_status>" and "<json_message>" with failure responds
    And the database does not have record

    Examples: Invalid mac_address format
      | information | value             | http_status | json_message      |
      | mac_address | @@@@@@@@@@        | 400         | invalid parameter |
      | mac_address | 6D-81-45-4B-1A-B8 | 400         | invalid parameter |
      | mac_address | A6:3A:B9:05:3E:B3 | 400         | invalid parameter |



  Scenario: [REST-00-03]
    Check standard device registration process

    When the device send information to REST API
    Then the API should return success respond
    And the record in databases as expected

  Scenario: [REST-00-04]
    Check reset process

    Given the device already registration
    And the device send reset request to REST API
    Then the API should return success respond
    And the databases should have not pairing record

  Scenario: [REST-00-05]
    Check correct update process when IP changed

    Given the device already registration
    And the device IP was be changed
    And the device send information to REST API
    Then the API should return success respond
    And the record in databases as expected

  Scenario: [REST-06]
    Check incorrect update process when signature invalid

    Given the device already registration
    And the device signature was be changed to "abcde"
    And the device send information to REST API
    Then the API should return "400" and "Failure" with error responds
    And the database does not have record

