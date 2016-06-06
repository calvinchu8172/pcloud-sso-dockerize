Feature: [REST_00_00] REST API testing

  Background:
    Given the device with information
      | mac_address      | 099789665701    |
      | serial_number    | A123456         |
      | model_name       | NSA325          |
      | firmware_version | 1.0             |
      | algo             | 1               |
      | ip_address       | 192.168.100.100 |

# ---------------------------------------------- #
# ----- Given the device is not registered ----- #
# ---------------------------------------------- #

  Scenario Outline: [REST_00_00_01]
    Check incorrect update process when invalid format
    Given the device is not registered 
      And the device "<information>" was be changed to "<value>"
      And the device send "register" request to REST API /d/1/register 
     Then the API should return "<http_status>" and "<json_message>" with "failure" responds
     And the database does not have record
    Examples: Invalid mac_address format
      | information | value             | http_status | json_message      |
      | mac_address | @@@@@@@@@@        | 400         | invalid parameter |
      | mac_address | 6D-81-45-4B-1A-B8 | 400         | invalid parameter |
      | mac_address | A6:3A:B9:05:3E:B3 | 400         | invalid parameter |

  Scenario: [REST_00_00_02]
    Check incorrect update process when signature invalid
    Given the device is not registered
      And the device "signature" was be changed to "abcde"
      And the device send "register" request to REST API /d/1/register
     Then the API should return "400" and "Failure" with "error" responds
      And the database does not have record

  Scenario: [REST_00_00_03]
    Check standard device registration process
     When the device send "register" request to REST API /d/1/register
     Then the API should return success respond
      And the record in databases as expected

# ------------------------------------------ #
# ----- Given the device is registered ----- #
# ------------------------------------------ #

  Scenario Outline: [REST_00_00_04]
    Check correct update process when valid format and IP changed
     Given the device is registered
      And the device "<information>" was be changed to "<value>"
      And the device send "register" request to REST API /d/1/register
     Then the API should return success respond
      And the record in databases as expected
    Examples: Valid format
      | information      | value            |
      | firmware_version | 2.0              |
      | ip_address       | 192.168.100.200  |

  Scenario: [REST_00_00_05]
    Check reset process
    Given the device is registered
      And the device send "reset" request to REST API /d/1/register
     Then the API should return success respond
      And the database should not have any pairing records

