Feature: [PCP_002_02] Change Password

  Background:
    Given the user is login and visits password change page

  Scenario:	[PCP_002_02_01]
    Show error message when password invaild on change password page

    When the user filled the incorrect current password
    And the user filled the new password <newpassword>
    And the user click submit for change password
    Then the user will get error message from change password

  Scenario: [PCP_002_02_02]
    Redirect to profile page when change password successfully

    When the user filled the correct current password
    And the user filled the new password <newpassword>
    And the user click submit for change password
    Then the user will get success message from change password
