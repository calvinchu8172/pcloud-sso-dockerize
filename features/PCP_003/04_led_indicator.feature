Feature: [PCP_003_04] LED Indicator

  Background:
    Given a user visits search devices page
    And the device connect
    And the user see the device in device list

  Scenario:  [PCP_003_04_01]
    Show "Find NAS" button when device is not paired and the device has indicator module

    When the connected device in the list is not paired
    And the connected device has the indicator module

    Then the user should see the enabled "Find NAS" button of the device

  Scenario:  [PCP_003_04_02]
    Disable "Find NAS" button for 30 seconds when the user click it

    When the user click the "Find NAS" button of the device

    Then the user should see the "Find NAS" button of the device disabled for 30 seconds
    And the NAS which the button related to should blinked its LED at the same time

    When the "Find NAS" button disabled already 30 seconds
    Then the user should see the "Find NAS" button enabled again

  Scenario:  [PCP_003_04_03]
    Hide "Find NAS" button when user paired the device completely

    When the user click "Pairing" link to start pairing
    And complete the pairing process

    Then the user should not see the "Find NAS" button of the paired device







