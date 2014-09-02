@javascript
Feature: [PCP_004_03] UPnP Setup
	Background:
    Given a user visit UPnP setup page

	Scenario:  [PCP_004_03_01]
	  Show synchronizing information

	  And the page will waiting for connection with device

	  Then the user should see "Synchronizing UPnP settings... " message on UPnP setup page

	Scenario:  [PCP_004_03_02]
	  Show "Device is not found" message when device was not connection
	  And the page will waiting for connection with device

	  When the device was offline

	  Then the user should see "Device is not found" message on UPnP setup page

	Scenario:  [PCP_004_03_03]
	  Show device information and service list
	  And the page will waiting for connection with device

	  When the device was online the device will response service list

	  Then the user should see service list

	Scenario:  [PCP_004_03_04]
	  Show success information when update successfully
	  And the page will waiting for connection with device

	  When the device was online the device will response service list

	  Given the user changed UPnP setting

	  When the user click "Submit" button
	  And the services was success updated

	  Then the user should see "UPnP settings have been successfully." message on UPnP setup page