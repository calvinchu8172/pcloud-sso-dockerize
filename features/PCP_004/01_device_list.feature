Feature: [PCP_004_01] Device Lists

	Background: 
		Given a user is registered and visits home page

	Scenario:  [PCP_004_01_01]
	  Redirect to search devices page when user didn't paired any devices

	  When the user didn't paired any devices
	  And the user will redirect to Search Results page

	Scenario:  [PCP_004_01_02]
	  Show devices list

	  When the user have device
	  Then the user should see device list
	  
	Scenario:  [PCP_004_01_03]
	  Show "DDNS is not Configured" when device didn't setting DDNS.
	  
	  When the user have device
	  And the user finished the pairing
	  Then the user should see "DDNS is not Configured" message in My Devices page
