Feature: [PCP_004_04] Unpairing

  Background:
    Given the user have a paired device
      And the user visits unpairing page

  Scenario:  [PCP_004_04_01]
    Show warning message and device information
     Then the user should see confirm message on unpairing confirm page

  Scenario:  [PCP_004_04_02]
    Redirect to My Devices page when user have other devices after unpairing
     When the user click "Confirm" link
     Then the user will redirect to success page
      And the user should see success message
      And the record of pairing should be removed
     When the user have other devices
      And the user click "Confirm" link
     Then the user will redirect to My Devices page

  Scenario:  [PCP_004_04_03]
    Redirect to search devices page when user have not other devices after unpairing
    Given the user successfully unpair device
     When the user have not other devices
      And the user click "Confirm" link
     Then the user will redirect to Search Device page

  Scenario:  [PCP_004_04_04]
    Redirect to My Devices page when user click cancel button on unpairing page
     When the user click "Cancel" link
     Then the user will redirect to My Devices page

  Scenario: [PCP_004_04_05]
    Delete pairing data and its associations, including Invitation, AcceptedUser
    Given the device has inviation and accepted_user
     When the user click "Confirm" link
     Then the record of pairing should be removed
      And the device relations of invitations and accepted_users are all deleted
