Feature: [PCP_002_02] Change Password

  Background:
    Given the user was login and visits change password page
      And the user has other 3 logined machines with account tokens and authentication tokens
      And the user should have 3 account tokens
      And the user should have 3 authentication tokens

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
      And the user's account tokens and authentication tokens should all revoked

   Scenario: [PCP_002_02_03]
    Redirect to profile page when user click cancel button in change password page
     When the user click "Cancel" link
     Then the page will redirect to profile page
