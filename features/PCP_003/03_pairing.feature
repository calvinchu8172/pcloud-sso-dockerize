Feature: [PCP_003_03] Pairing

	Background: 
	  Given a user visit device's pairing page

	Scenario:  [PCP_003_03_01]
	  Show check information on first step

	  Then the user should see the device

	Scenario:  [PCP_003_03_02]
	  Show countdown and pairing information when pairing start 

	  When the user click "Confirm"
		Then the user should see the countdown and pairing information
	  
	Scenario:  [PCP_003_03_03]
	  Show "Device is not found" message when device was not connection
	  
	  When the user click "Confirm"
	  Then the user should see "Successfully paired."

	Scenario:  [PCP_003_03_04]
	  Show timeout information

	  When the user click "Confirm"
	  Then the user should see "Device is not found"

	Scenario:  [PCP_003_03_05]
	  Show paired information and redirect to DDNS setting page when click confirm button

	  When the user click "Confirm"
	  Then the user should see "Successfully paired."
	  And the user click "Confirm"
	  Then the user will redirect to "/personal/index"