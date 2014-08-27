Feature: [PCP_004_04] Unpairing

	Background:
    Given a user have pairing device

	Scenario:  [PCP_004_04_01]
	  Show warning message and device information

    When the user visit device unpairing page
	  Then the user should see unpairing feature "Are you sure" message

	Scenario:  [PCP_004_04_02]
	  Show unpairing message

    When the user visit device unpairing page
	  When the user click "Confirm" button in pairing page
	  Then the user should see unpairing feature "successfully unpaired" message