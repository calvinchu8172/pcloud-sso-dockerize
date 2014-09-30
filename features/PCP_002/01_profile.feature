Feature: [PCP_002_01] Profile

  Background:
    Given a user visits profile page

  Scenario: [PCP_002_01_01]
    Show user profile if items was not blank

    Then the user should see profile

  Scenario: [PCP_002_01_02]
    Show error message when display name was blank on edit profile page

    Given the user visits "Edit Profile" page
    And the user clean the display name

    When the user click "Submit" button

    Then the user should see the error message under the "Display as"

  Scenario: [PCP_002_01_03]
    Redirect to profile page when edit successfully

    Given the user visits "Edit Profile" page
    And the user changed the display name

    When the user click "Submit" button

    Then the user's profile has been updated
    And display successfully information on profile page

  Scenario Outline: [PCP_001_02_04]
    Test each field length

    Given the user visits "Edit Profile" page
    And the user filled the user information over length limit
      | Text field        | length limit           |
      | Display as        | 255                    |
      | First Name        | 255                    |
      | Middle Name       | 255                    |
      | Last Name         | 255                    |
      | Mobile Number     | 40                     |

    Then the user should see error message for over length limit

    Examples:
      | Text field        |
      | Display as        |
      | First Name        |
      | Middle Name       |
      | Last Name         |
      | Mobile Number     |

   Scenario: [PCP_002_01_05]
    Redirect to profile page when user click cancel button in profile page

    Given the user visits "Edit Profile" page
    And the user click "Cancel" link

    Then the user will redirect to profile page
