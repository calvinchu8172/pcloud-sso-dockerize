@javascript
Feature: [PCP_005_01] Accept Invitation

  Background:
    Given an existing user's account and password
    And an existing device with pairing signed in client without xmpp
    And 1 existing invitation record

  Scenario: [PCP_005_01_01]
    Redirect to login page when user not login

    When a user visits accept invitation page

    Then the page will redirect to login page


  Scenario: [PCP_005_01_02]
    Show error messages when invitation key invalid

    Given the invalid invitation key
    And user logined

    When a user visits accept invitation page

    Then the invitation page should see an error message for "Invitation accept failed"

  Scenario: [PCP_005_01_03]
    Show error messages when visitor own the device

    Given user logined who generate invitation key

    When a user visits accept invitation page

    Then the invitation page should see an error message for "Invitation accept failed"

  Scenario: [PCP_005_01_04]
    Show timeout message when requset timeout

    Given user logined
    And connect over 30 sec and server send "timeout" message

    When a user visits accept invitation page

    Then the visitor should see a "Invitation accept failed" message and button for "Retry"

  Scenario: [PCP_005_01_05]
    Show error message when already accepted by user

    Given user logined
    And user already acceped this invitation

    When a user visits accept invitation page

    Then the invitation page should see an error message for "Invitation accept failed"

  Scenario: [PCP_005_01_06]
    Show error message when invitation key counting expired

    Given user logined
    And the invitation key expire count is zero

    When a user visits accept invitation page

    Then the invitation page should see an error message for "Invitation accept failed"

  Scenario: [PCP_005_01_07]
    Show success message when server return done message in time

    Given user logined
    And connect success and server send success message

    When a user visits accept invitation page

    Then the visitor should see a "Invitation accept success" message and button for "Confirm"

  Scenario: [PCP_005_01_08]
    Redirect user to login page when click "Confirm" button

    Given user logined
    And connect success and server send success message

    When a user visits accept invitation page
    And user click "Confirm" button

    Then user will redirect to login page

  Scenario: [PCP_005_01_09]
    Redirect user to accept invitation page when click "Retry" button

    Given user logined
    And connect over 30 sec and server send "timeout" message

    When a user visits accept invitation page
    And user click "Retry" button

    Then the visitor should reload this page for retry
