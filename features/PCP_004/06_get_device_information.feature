@javascript
Feature: [PCP_004_007] Get Device Information

  Background:
    Given a user was signin and visits home page
    And the user have already paired device

  Scenario: [PCP_004_006_001]
    Show device information when user click down arrow button

    When user click on down arrow button
    And device feedback device info with:
      | volumn_name    | volumn_ecowork |
      | used_capacity  | 100            |
      | total_capacity | 1000           |

    Then the page should display device information
    And the page should include up arrow button

  Scenario: [PCP_004_006_002]
    Close device information when user click up arrow button

    When user click on down arrow button
    And user click on up arrow button

    Then the page should not display device information

  Scenario: [PCP_004_006_003]
    Only show one device information when user click down arrow button

    Given user have another paired device

    When user click on down arrow button and then click on another down arrow button

    Then the page should display only one down arrow button

  Scenario Outline: [PCP_004_006_004]
    Display Available capacity

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

  Scenario Outline: [PCP_004_006_005]
    Display volumn capacity

    When user click on down arrow button
    And device feedback device info with:
      | volumn_name    | volumn_ecowork   |
      | used_capacity  | <used_capacity>  |
      | total_capacity | <total_capacity> |

    Then the volumn capacity should display: <display_total>

    Examples:
      | total_capacity | used_capacity | display_total |
      | 4096           | 1000          | 4.0           |

  Scenario Outline: [PCP_004_006_006]
    Switch display volumn capacity unit

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
