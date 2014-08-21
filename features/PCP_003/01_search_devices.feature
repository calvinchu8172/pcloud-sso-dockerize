Feature: [PCP_003_01] Search Devices

	Background: 
	  Given a user visit search devices

	Scenario:  [PCP_003_01_01]
	  Show "Device is not found" message when device was not connection

	  When the user haven't any devices
	  Then the user should see "Device is not found"

	Scenario:  [PCP_003_01_02]
	  Show connected devices list

	  When the user have device
	  Then the user should see device 