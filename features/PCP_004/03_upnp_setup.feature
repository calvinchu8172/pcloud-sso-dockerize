@javascript
Feature: [PCP_004_03] UPnP Setup
	Background:
    Given a user visit UPnP setup page

	Scenario: [PCP_004_03_01]
	  Show synchronizing information

	  And the page will waiting for connection with device

	  Then the user should see "Synchronizing UPnP settings... " message on UPnP setup page

	Scenario: [PCP_004_03_02]
	  Show "Device is not found" message when device was not connection
	  And the page will waiting for connection with device

	  When the device was offline

	  Then the user should see "Device is not found" message on UPnP setup page

	Scenario: [PCP_004_03_03]
	  Show device information and service list
	  And the page will waiting for connection with device

	  When the device was online the device will response service list

	  Then the user should see service list

	Scenario: [PCP_004_03_04]
	  Show success information when update successfully
	  And the page will waiting for connection with device

	  When the device was online the device will response service list

	  Given the user changed UPnP setting

	  When the user click "Submit" button
	  And the services was success updated

	  Then the user should see "UPnP settings have been successfully." message on UPnP setup page

	Scenario: [PCP_004_03_05]
		Redirect to My Devices page when user completely cancel the UPnP setup flow
	  And the page will waiting for connection with device

		When the user click "Cancel" button

		Then the user will see the confirm message about cancel UPnP setup

		When the user click "Confirm" link

		Then the user will redirect to My Devices page after cancel

	Scenario:	[PCP_004_03_06]
		The UPnP setup should continue when user click cancel but the user want to go back to setup flow
		And the page will waiting for connection with device

		When the user click "Cancel" button

		Then the user will see the confirm message about cancel UPnP setup

		When the user click "Cancel" button

		Then the user will go back to setup flow

	Scenario: [PCP_004_03_07]
		Disable any button when process of UPnP setting is waiting, except the cancel button
		And the page will waiting for connection with device

		When the user want to click link without cancel

		Then it should not do anything on UPnP setup page
