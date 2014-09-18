Feature: [PCP_004_04] Unpairing

	Background:
    Given the user have a paired device
    And the user visits unpairing page

	Scenario:  [PCP_004_04_01]
	  Show warning message and device information

	  Then the user should see "Are you sure" message on unpairing page

	Scenario:  [PCP_004_04_02]
	  Show unpairing message

	  When the user click "Confirm" link

	  Then the user should see "successfully unpaired" message on unpairing page