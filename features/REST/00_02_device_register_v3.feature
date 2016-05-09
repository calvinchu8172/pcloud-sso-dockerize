Feature: [REST_00_02] Device Register V3

  Background:
    Given the device with information
      | mac_address      | 099789665701  |
      | serial_number    | A123456       |
      | model_name       | NSA325        |
      | firmware_version | 1.0           |
      | algo             | 1             |
      | ip_address       | 192.168.50.10 |

  Scenario Outline: [REST_00_02_01]
    Check correct update process when valid format
     When the device already registration
      And the device "<information>" was be changed to "<value>"
      And the device IP was be changed to "192.168.50.11"
      And the device send information to REST API /d/3/register
     Then the API should return success respond
      And the record in databases as expected
    Examples: Valid format
      | information      | value             |
      | firmware_version | 2.0               |
      | mac_address      | 000000000000      |
      | serial_number    | 654321A           |

  Scenario Outline: [REST_00_02_02]
    Check incorrect update process when invalid format
    Given the device already registration
      And the device "<information>" was be changed to "<value>"
     When the device send information to REST API /d/3/register
     Then the API should return "<http_status>" and "<json_message>" with failure responds
      And the database does not have record
    Examples: Invalid mac_address format
      | information | value             | http_status | json_message      |
      | mac_address | @@@@@@@@@         | 400         | invalid parameter |
      | mac_address | 6D-81-45-4B-1A-B8 | 400         | invalid parameter |
      | mac_address | A6:3A:B9:05:3E:B3 | 400         | invalid parameter |
      | model_name  | UNKNOWN           | 400         | invalid parameter |

  Scenario: [REST_00_02_03]
    Check standard device registration process
     When the device send information to REST API /d/3/register
     Then the API should return success respond
      And the record in databases as expected

  Scenario: [REST_00_02_04]
    Check reset process
    Given the device already registration
      And the device has inviation and accepted_user
     When the device send reset request to REST API /d/3/register
     Then the API should return success respond
      And the databases should have not pairing record
      And the database should have no any association data with this device, including Invitation and AcceptedUser

  Scenario: [REST_00_02_05]
    Check correct update process when IP changed
    Given the device already registration
      And the device has a DDNS record, and ip is "9.9.9.9"
      And the device IP was be changed to "1.2.3.4"
     When the device send information to REST API /d/3/register
     Then the API should return success respond
      And the record in databases as expected
    #   And DDNS ip should be update to "01020304"
      And the ip in device session should be the same as "1.2.3.4"

  Scenario: [REST_00_02_06]
    Check incorrect update process when signature invalid
    Given the device already registration
      And the device signature was be changed to "abcde"
     When the device send information to REST API /d/3/register
     Then the API should return "400" and "Invalid signature" with error responds
      And the database does not have record

  Scenario: [REST_00_02_07]
    Record device module with valid input
    Given the device module information
     When the device send information to REST API /d/3/register
     Then the API should return success respond
      And the module record in database as expected

  Scenario: [REST_00_02_08]
    Validate valid signature by RSA key and Certificate
     When the device send information to REST API /d/3/register
     Then the API should return success respond

  Scenario: [REST_00_02_09]
    Check XmppServer should save device register sign in time
     When the device send information to REST API /d/3/register
     Then XmppLast should record this device register sign in time

  Scenario Outline: [REST_00_02_10]
    Check device's IP address being same as in database every time it registered
     When the device's IP is "<IP>"
      And the device send information to REST API /d/3/register
     Then the database should have the same IP record
    Examples:
      |      IP     |
      | 192.100.1.0 |
      | 192.100.1.1 |
      | 192.100.1.2 |
