Feature: Device Register V3 Lite

  Background:
    Given the device with information
      | mac_address      | 099789665701 |
      | serial_number    | A123456      |
      | model_name       | NSA325       |
      | firmware_version | 1.0          |
      | algo             | 1            |

    And an existing certificate and RSA key

    Scenario Outline: [REST_00_03_01]
      Check correct update process when valid format

      When the device already registration
      And the device "<information>" was be changed to "<value>"
      And the device send information to REST API /d/3/register/lite

      Then the API should return success respond

      Examples: Valid format
      | information      | value             |
      | firmware_version | 2.0               |
      | mac_address      | 000000000000      |
      | serial_number    | 654321A           |

    Scenario Outline: [REST_00_03_02]
      Check incorrect update process when invalid format

      Given the device already registration
      And the device "<information>" was be changed to "<value>"

      When the device send information to REST API /d/3/register/lite

      Then the API should return "<http_status>" and "<json_message>" with failure responds

      Examples: Invalid mac_address format
      | information | value             | http_status | json_message      |
      | mac_address | @@@@@@@@@         | 400         | invalid parameter |
      | mac_address | 6D-81-45-4B-1A-B8 | 400         | invalid parameter |
      | mac_address | A6:3A:B9:05:3E:B3 | 400         | invalid parameter |
      | model_name  | UNKNOWN           | 400         | invalid parameter |

    Scenario: [REST_00_03_03]
      Check standard device registration process

      When the device send information to REST API /d/3/register/lite

      Then the API should return success respond

    Scenario: [REST_00_03_04]
      Check correct update process when IP changed

      Given the device already registration
      And the device IP was be changed

      When the device send information to REST API /d/3/register/lite

      Then the API should return success respond

    Scenario: [REST_00_03_05]
      Check incorrect update process when signature invalid

      Given the device already registration
      And the device signature was be changed to "abcde"

      When the device send information to REST API /d/3/register/lite

      Then the API should return "400" and "Invalid signature" with error responds

    Scenario: [REST_00_03_06]
      Validate valid signature by RSA key and Certificate

      When the device send information to REST API /d/3/register/lite

      Then the API should return success respond
