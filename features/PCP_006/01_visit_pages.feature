Feature: [PCP_006_01] Visit Pages

  Scenario: [PCP_006_01_01]
    The user click help link
    Given the user is in the sign in page
     When the user click "Help" link
     Then the user should see the help page

  Scenario: [PCP_006_01_02]
    The user click support link
    Given the user is in the sign in page
     When the user click "Support" link
     Then the user should see the support page
