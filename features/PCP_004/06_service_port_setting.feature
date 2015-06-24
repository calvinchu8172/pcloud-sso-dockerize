Feature: [PCP_004_06] Service Port Setting

  Background:
    Given a user visit UPnP setup page
    And the device is online and response service list successfully

  Scenario: [PCP_004_06_01]
    Show port number of each service when user click "Show Service Port"

    When user click "Show Service Port"

    Then user should see port number of each service

    And the "Show Service Port" button should be replaced by "Hide Service Port" button


  Scenario: [PCP_004_06_01]
    Auto renew a port number between 1025 and 65535 for those disabled service in service list

    When device response the service list
    And some services in the list are disabled

