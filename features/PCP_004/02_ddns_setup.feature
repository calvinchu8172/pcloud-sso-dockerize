@javascript
Feature: [PCP_004_02] DDNS Setup

  Background:
    Given the user have a paired device
      And the user visits DDNS setup page

  Scenario Outline:  [PCP_004_02_01]
    Show error message when hostname invalid
      And the user filled the invalid Hostname <Hostname>
     When the user click "Submit" button
     Then the user should see error message for Hostname
    Examples:
      | Hostname |
      | hi       |
      | hi@      |
      | 0A0      |
      | 1234567890123456789012345678901234567890123456789012345678901234 |

  Scenario:  [PCP_004_02_02]
    Show error message when hostname exists
    Given the user filled the exist Hostname
     When the user click "Submit" button
     Then the user should see error message for Hostname

  Scenario:  [PCP_004_02_03]
    Redirect to success page when hostname update
      And the user filled the valid Hostname
     When the user click "Submit" button
      And the server update DDNS setting successfully
     Then the user should see success message on DDNS setup page

  Scenario:  [PCP_004_02_04]
    Redirect to UPnP setup page if device is new one
      And the user filled the valid Hostname
     When the user click "Submit" button
      And the server update DDNS setting successfully
    Given the device was first setting DDNS after paired
     When the user click "Confirm" link
     Then the user will redirect to My Devices page

  Scenario:  [PCP_004_02_05]
    Redirect to My Devices page when user click cancel button in DDNS setup page
     When the user click "Cancel" link
     Then the user will redirect to My Devices page

  Scenario:  [PCP_004_02_06]
    Show error message when hostname was used in user's devices
     When the device already registered hostname <already>
     When the user have other devices
      And the user visits another device DDNS setup page
      And the user filled the invalid Hostname <already>
      And the user click "Submit" button
     Then the user should see error message for Hostname

  Scenario:  [PCP_004_02_07]
    Show error message when hostname exists
    Given the user filled the reserved Hostname
     When the user click "Submit" button
     Then the user should see error message for Hostname

  Scenario:  [PCP_004_02_08]
    Show error message when device not found
     When the user visits DDNS setup page with un-existed device id
     Then the user should see error message "not found"
