Feature: [PCP_004_04] Unpairing

	Background: 
	  Given a user visit device unpairing page

	Scenario:  [PCP_004_04_01]
	  Show warning message and device information

	  Then the user should see unpairing feature "Are you sure" message

	Scenario:  [PCP_004_04_02]
	  Show unpairing message

	  When the user click "Confirm"
	  Then the user should see unpairing feature "successfully unpaired" message