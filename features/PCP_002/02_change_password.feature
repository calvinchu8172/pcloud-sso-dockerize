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

  Scenario Outline: [PCP_002_02_03]
    Test each field length

    When the user filled the user information over length limit
      | Text field        | length limit           |
      | E-mail            | 255                    |
      | Password          | 14                     |
      | Display as        | 255                    |
      | First Name        | 255                    |
      | Middle Name       | 255                    |
      | Last Name         | 255                    |
      | Mobile Number     | 40                     |

    Then the user should see error message for over length limit

    Examples:
      | Text field        |
      | E-mail            |
      | Password          |
      | Display as        |
      | First Name        |
      | Middle Name       |
      | Last Name         |
      | Mobile Number     |

