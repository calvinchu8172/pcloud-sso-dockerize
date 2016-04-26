@javascript
Feature: [PCP_004_06] Get Device Information

  Background:

  Scenario: [PCP_004_06_01]
    Show device information when user click down arrow button
    Given a user was signin and visits home page
      And the user have already paired device
     When user click on down arrow button
      And device feedback device info with:
      | volumn_name    | volumn_ecowork |
      | used_capacity  | 100            |
      | total_capacity | 1000           |
     Then the page should display device information
      And the page should include up arrow button

  Scenario: [PCP_004_06_02]
    Close device information when user click up arrow button
    Given a user was signin and visits home page
      And the user have already paired device
     When user click on down arrow button
      And user click on up arrow button
     Then the page should not display device information

  Scenario: [PCP_004_06_03]
    Only show one device information when user click down arrow button
    Given a user was signin and visits home page
      And the user have already paired device
    Given user have another paired device
     When user click on down arrow button and then click on another down arrow button
     Then the page should display only one down arrow button

  Scenario Outline: [PCP_004_06_04]
    Display Available capacity
    Given a user was signin and visits home page
      And the user have already paired device
     When user click on down arrow button
      And device feedback device info with:
      | volumn_name    | volumn_ecowork   |
      | used_capacity  | <used_capacity>  |
      | total_capacity | <total_capacity> |
     Then the available capacity should display: <display>
      And the available capacity percentage should be: <percentage>
    Examples:
      | total_capacity  | used_capacity | display       | percentage   |
      | 4095          | 500         | 4095        | 87.79%          |
      | 4096          | 1000        | 4.0          | 75.00%          |

  Scenario Outline: [PCP_004_06_05]
    Display volumn capacity
    Given a user was signin and visits home page
      And the user have already paired device
     When user click on down arrow button
      And device feedback device info with:
      | volumn_name    | volumn_ecowork   |
      | used_capacity  | <used_capacity>  |
      | total_capacity | <total_capacity> |
     Then the volumn capacity should display: <display_total>
    Examples:
      | total_capacity | used_capacity | display_total |
      | 4096           | 1000          | 4.0           |

  Scenario Outline: [PCP_004_06_06]
    Switch display volumn capacity unit
    Given a user was signin and visits home page
      And the user have already paired device
     When user click on down arrow button
      And device feedback device info with:
      | volumn_name    | volumn_ecowork   |
      | used_capacity  | <used_capacity>  |
      | total_capacity | <total_capacity> |
      And click on volumn div
     Then the volumn capacity should display: <display_total>
    Examples:
      | total_capacity | used_capacity | display_total |
      | 4096            | 1000          | 4096          |

  Scenario: [PCP_004_06_07]
    Forbid getting device information if user requests device info over 5 times in 1 minute
    ( device info limit session will expired after 1 minute )
    Given a user was signin and visits home page
      And the user have already paired device
     When user click on down arrow button and up arrow button over 5 times
     When user click on down arrow button
     Then the page should not display device information
