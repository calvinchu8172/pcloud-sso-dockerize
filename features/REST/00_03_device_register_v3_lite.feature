Feature: [REST_00_03] Device Register V3 Lite

# ---------------- #
# ----- Note ----- #
# ---------------- #
# /d/3/register/lite 功能：
# * 使 Personal Cloud Findme 可透過 redis session 中找到對應的 device。
# * lite 僅會寫入 redis，不會儲存資料在 DB 中，寫入的欄位包含：
#    + origin_id, => redis hash key: "mac_address + serial_number"
#    + mac_address,
#    + serial_number,
#    + model_class_name,
#    + firmware_version,
#    + ip_address,
#    + lan_ip

  Background:
    Given the device with information
      | mac_address      | 099789665701     |
      | serial_number    | A123456          |
      | model_name       | NSA325           |
      | firmware_version | 1.0              |
      | algo             | 1                |
      | ip_address       | 192.168.100.100  |
      And an existing certificate and RSA key

# ---------------------------------------------- #
# ----- Given the device is not registered ----- #
# ---------------------------------------------- #

  Scenario Outline: [REST_00_03_01]
    Check incorrect update process when invalid format
    Given the device is not registered
      And the device "<information>" was be changed to "<value>"
     When the device send "register" request to REST API /d/3/register/lite
     Then the API should return "<http_status>" and "<json_message>" with "failure" responds
    Examples: Invalid mac_address format
      | information | value             | http_status | json_message      |
      | mac_address | @@@@@@@@@         | 400         | invalid parameter |
      | mac_address | 6D-81-45-4B-1A-B8 | 400         | invalid parameter |
      | mac_address | A6:3A:B9:05:3E:B3 | 400         | invalid parameter |

  Scenario: [REST_00_03_02]
    Check incorrect update process when signature invalid
    Given the device is not registered
      And the device "signature" was be changed to "abcde"
     When the device send "register" request to REST API /d/3/register/lite
     Then the API should return "400" and "Invalid signature" with "error" responds

  Scenario: [REST_00_03_03]
    Check standard device registration process
    Given the device is not registered
     When the device send "register" request to REST API /d/3/register/lite
     Then the API should return success respond

# ------------------------------------------ #
# ----- Given the device is registered ----- #
# ------------------------------------------ #

  Scenario Outline: [REST_00_03_01]
    Check correct update process when valid format and IP changed
     When the device is registered
      And the device "<information>" was be changed to "<value>"
      And the device send "register" request to REST API /d/3/register/lite
     Then the API should return success respond
    Examples: Valid format
      | information      | value             |
      | firmware_version | 2.0               |
      | ip_address       | 192.168.100.200   |

