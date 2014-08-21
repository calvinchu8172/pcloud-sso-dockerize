Feature: [PCP_004_03] UPnP Setup

	Background: 
    Given a user visit device upnp page

	Scenario:  [PCP_004_03_01]
	  Show synchronizing information

	  And the user should see "Synchronizing UPnP settings... "

	Scenario:  [PCP_004_03_02]
	  Show "Device is not found" message when device was not connection

	  And the user should see "Device is not found"

	Scenario:  [PCP_004_03_03]
	  Show device information and service list

	  And the user should see upnp setting table
	  
	Scenario:  [PCP_004_03_04]
	  Show success information when update successfully

	  And the user should see "UPnP settings have been successfully."