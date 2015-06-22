Feature: [PCP_005_01] Accept Invitation

  Background:
    Given a user visits accept invitation page

  Scenario: [PCP_005_01_01]
    Redirect to login page when user not login

    When the visitor not login

    Then the page will redirect to login page


  Scenario Outline: [PCP_005_01_02]
    Show error messages when invitation key invalid

    When the invitation key invalid
    And user logined
    Then the visitor should see an error message for "invalid invitation key"

    Examples:
      | Invitation Key        |
      |                       |
      | 12312345              |
      | personal@             |
      | personal.example.com  |

  Scenario: [PCP_005_01_03]
    Show error messages when visitor own the device

    When user logined
    And the user paired the device of invitation
    Then the visitor should see an error message for "Owner can not be invited"

  Scenario: [PCP_005_01_04]
    Show timeout message when requset timeout

    When user logined
    And connect over 30 sec and server send "timeout" message
    Then the visitor should see a timeout message for and button for "retry"

  Scenario: [PCP_005_01_05]
    Show error message when already accepted by user

    When user logined
    And user already acceped this invitation
    Then the visitor should see an error message for "Already accepted"

  Scenario: [PCP_005_01_06]
    Show error message when invitation key counting expired

    When user logined
    And the invitation key counting = 0
    Then the visitor should see an error message for "Invitation key counting expired"

  Scenario: [PCP_005_01_07]
    Show success message when server return done message in time

    When user logined
    And invitation key is vaild and not expired
    And receive "done" message
    Then the visitor should see a success message and button for "confirm"

  Scenario: [PCP_005_01_08]
    Redirect user to discover page when click "confirm" button

    When user success in accept invitation
    And user click "confirm" button
    Then the visitor should redirect to discover page

  Scenario: [PCP_005_01_09]
    Redirect user to accept invitation page when click "retry" button

    When user click retry button
    Then the visitor should reload this page for retry
