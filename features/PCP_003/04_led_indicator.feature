@javascript
Feature: [PCP_003_04] LED Indicator

  Background:
    Given a user visited search devices page
    And the device connected
    And the user saw the device in device list

  Scenario:  [PCP_003_04_01]
    Show "Find NAS" button when device is not paired and the device has indicator module

    When the connected device in the list is not paired
    And the device has "indicator" module
    Then the user should see the enabled "Find NAS" button of the device

  Scenario:  [PCP_003_04_02]
    Disable "Find NAS" button for 30 seconds when the user click it

    When the user click the "Find NAS" button of the device
    Then the user should see the "Find NAS" button of the device disabled for 30 seconds

    When the "Find NAS" button has already disabled 30 seconds and NAS accepted pairing
    Then the user should see the "Find NAS" button enable again

  Scenario:  [PCP_003_04_03]
    Hide "Find NAS" button when user paired the device completely

    When the user clicked "Pairing" link to start pairing
    And the user has completed the pairing process
    Then the user should not see the "Find NAS" button of the paired device
