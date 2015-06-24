Feature: [PCP_004_007] Get Device Information

  Background:
    Given a user was signin and visits home page
    And the user have already paired device

  Scenario: [PCP_004_007_001]
    Show device information when user click down arrow button

    When user click on down arrow button

    Then the page should display device information
    And the page should include up arrow button

  Scenario: [PCP_004_007_002]
    Close device information when user click up arrow button

    When user click on down arrow button
    And user click on up arrow button

    Then the page should not display device information

  Scenario: [PCP_004_007_003]
    Only show one device information when user click down arrow button

    Given user have another paired device

    When user click on down arrow button
    And user click on another down arrow button

    Then the page should display another device information

  Scenario Outline: [PCP_004_007_004]
    Display Available capacity

    Given the user have a piared device with total capacity: <total_capacity>, used capacity: <used_capacity>

    When user click on down arrow button

    Then the available capacity should display: <display>
    And the available capacity percentage should be: <percentage>

    Examples:
      | total_capacity  | used_capacity | display       | percentage   |
      | 4095MB          | 500MB         | 4095MB        | 12%          |
      | 4096MB          | 1000MB        | 4GB           | 24%          |

  Scenario Outline: [PCP_004_007_005]
    Display volumn capacity

    Given the user have a piared device with total capacity: <total_capacity>, used capacity: <used_capacity>

    When user click on down arrow button

    Then the volumn capacity should display: <display>

    Examples:
      | total_capacity  | used_capacity | display_total | display_used |
      | 4096MB          | 1000MB        | 4.0GB         | 1.0GB        |

  Scenario Outline: [PCP_004_007_006]
    Switch display volumn capacity unit

    Given the user have a piared device with total capacity: <volumn_capacity>, used capacity: <used_capacity>

    When user click on down arrow button
    And click on volumn div

    Then the volumn capacity should display: <display>

    Examples:
      | volumn_capacity | used_capacity | display_total | display_used |
      | 4096MB          | 1000MB        | 4096MB        | 1000MB       |
