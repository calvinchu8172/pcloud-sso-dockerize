Feature: [PCP_003_01] Search Devices

	Background: 
	  Given a user visits search devices page

	Scenario:  [PCP_003_01_01]
	  Show "Device is not found" message when device was not connection

	  When the user have not any devices
	  Then the user should not see search devices feature devices list

	@javascript  
	Scenario:  [PCP_003_01_02]
	  Show connected devices list

	  When the user have a device
	  Then the user should see search devices feature devices list