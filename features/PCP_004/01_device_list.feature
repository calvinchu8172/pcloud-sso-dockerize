Feature: [PCP_004_01] Device Lists

	Background:
		Given a user was signin and visits home page

	Scenario: [PCP_004_01_01]
	  Redirect to search devices page when user didn't paired any devices
	   When the user have not paired devices
	   Then the user will redirect to Search Results page

	Scenario: [PCP_004_01_02]
	  Show devices list
	   When the user have already paired device
	   Then the user should see device list

	Scenario: [PCP_004_01_03]
	  Show "DDNS is not Configured" when device didn't setting DDNS.
	   When the user have already paired device
	   Then the user should see "DDNS is not Configured" message on My Devices page
