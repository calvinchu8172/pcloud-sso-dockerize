@javascript
Feature: [PCP_003_01] Search Devices

	Background:
	  Given a user visits search devices page

	Scenario: [PCP_003_01_01]
	  Show "Device is not found" message when device was not connection
	   When the device didn't connection
	   Then the user should not see devices list

	Scenario: [PCP_003_01_02]
	  Show connected devices list
	   When the device connect
	   Then the user should see devices list

	Scenario: [PCP_003_01_03]
	  The user should not see device is paired by another user
	   When another user paired the devics
	   Then the user should not see this device is paired by another user
