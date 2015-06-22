@javascript
Feature: [PCP_004_05] Package Setup
  Background:
    Given a user visit Package setup page

  Scenario: [PCP_004_05_01]
    Show synchronizing information

    And the page will waiting for connection with device

    Then the user should see "Synchronizing Package settings... " message on Package setup page

  Scenario: [PCP_004_05_02]
    Show "Device is not found" message when device was not connection
    And the page will waiting for connection with device

    When the device was offline

    Then the user should see "Device is not found" message on Package setup page

  Scenario: [PCP_004_05_03]
    Show device information and package name list
    And the page will waiting for connection with device

    When the device was online the device will response package name list

    Then the user should see package name list

  Scenario: [PCP_004_05_04]
    Show success information when update successfully
    And the page will waiting for connection with device

    When the device was online the device will response package name list

    Given the user changed Package setting

    When the user click "Submit" button

    And the services was success updated

    Then the user should see "Package settings have been successfully." message on Package setup page

  Scenario: [PCP_004_05_05]
    Redirect to My Devices page when user completely cancel the Package setup flow
    And the page will waiting for connection with device

    When the user click "Cancel" button

    Then the user will see the confirm message about cancel Package setup

    When the user click "Confirm" link

    Then the user will redirect to My Devices page after cancel

  Scenario: [PCP_004_05_06]
    The Package setup should continue when user click cancel but the user want to go back to setup flow
    And the page will waiting for connection with device

    When the user click "Cancel" button

    Then the user will see the confirm message about cancel Package setup

    When the user click "Cancel" button

    Then the user will go back to setup flow

  Scenario: [PCP_004_05_07]
    Disable any button when process of Package setting is waiting, except the cancel button
    And the page will waiting for connection with device

    When the user want to click link without cancel

    Then it should not do anything on Package setup page
