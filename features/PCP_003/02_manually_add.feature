Feature: [PCP_003_02] Manually Add

  Background:
    Given a user visits manually add page

  Scenario Outline: [PCP_003_02_01]
    Show error messages when mac address invalid
      And the user filled the invalid "Mac Address" <Mac Address>
     When the user click "Submit" button
     Then the user should see error message for mac address
    Examples:
      | Mac Address        |
      | %%:%%:%%:%%:%%:%%  |
      | GE:00:33:AR:00:00  |
      | 00:00:00:00:00:00: |
      | 000000000000	     |

  Scenario: [PCP_003_02_02]
    Show error messages when device not found
      And the user filled the not exists device information
     When the user click "Submit" button
     Then the user should see error message on manually add page

  Scenario: [PCP_003_02_03]
    Redirect to pairing page when device connecting
      And the user filled the exists device information
     When the user click "Submit" button
     Then the user will redirect to pairing check page

  Scenario: [PCP_003_02_04]
    Redirect to pairing page when device of NSA325 connecting
      And the user filled the device information of NSA325
     When the user click "Submit" button
     Then the user will redirect to pairing check page of NSA325

  Scenario: [PCP_003_02_05]
    Redirect to search devices page when user click cancel button in manually add page
     When the user click "Cancel" link
     Then redirect to Search Devices page

  Scenario: [PCP_003_02_06]
    Show error messages when device not found
      And the user filled the not exists device information with valid mac_address and invalid serial_number
     When the user click "Submit" button
     Then the user should see error message on manually add page
