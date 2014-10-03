Feature: [PCP_002_02] Change Password

  Background:
    Given the user was login and visits change password page

  Scenario:	[PCP_002_02_01]
    Show error message when password invaild on change password page

    When the user filled in current password was incorrect
    And the user filled the new password
    And the user click submit for change password
    Then the user will get error message from change password

  Scenario: [PCP_002_02_02]
    Redirect to profile page when change password successfully

    When the user filled in current password
    And the user filled the new password
    And the user click submit for change password
    Then the user will get success message from change password

   Scenario: [PCP_002_02_04]
    Redirect to profile page when user click cancel button in change password page

    When the user click "Cancel" link

    Then the page will redirect to profile page
