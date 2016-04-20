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

   Scenario: [PCP_002_01_04]
    Redirect to profile page when user click cancel button in profile page
    Given the user visits "Edit Profile" page
     When the user click "Cancel" link
     Then the page will redirect to profile page
