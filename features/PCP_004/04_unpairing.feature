Feature: [PCP_004_04] Unpairing

	Background: 
	  Given a user visit device unpairing page

	Scenario:  [PCP_004_04_01]
	  Show synchronizing information

	  When the user click "Confirm"
	  Then the user should see "UPnP settings have been successfully."

	Scenario:  [PCP_004_04_02]
	  Show "Device is not found" message when device was not connection

	  When the user click "Confirm"
	  Then the user should see "Device is not found"

	Scenario:  [PCP_004_04_03]
	  Show device information and service list

	  When the user click "Confirm"
	  Then the user should see device information
	  
	Scenario:  [PCP_004_04_04]
	  Show success information when update successfully

	  When the user click "Confirm"
	  Then the user should see "Device was successfully unpaired."

