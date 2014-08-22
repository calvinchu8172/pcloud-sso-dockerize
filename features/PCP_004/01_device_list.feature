Feature: [PCP_004_01] Device Lists

	Background: 
		Given a user visit My Devices page

	Scenario:  [PCP_004_01_01]
	  Redirect to search devices page when user didn't paired any devices

	  When the user haven't device
	  And the user will redirect to "/discoverer/index"
	  Then the user shold see device list feature "No device have been paired." message

	Scenario:  [PCP_004_01_02]
	  Show devices list

	  When the user have device
	  Then the user should see device list
	  
	Scenario:  [PCP_004_01_03]
	  Show "DDNS is not Configured" when device didn't setting DDNS.
	  
	  When the user have device
	  Then the user should see device list feature "DDNS is not Configured" message
