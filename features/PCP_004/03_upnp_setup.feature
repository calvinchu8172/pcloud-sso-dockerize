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

	Scenario:  [PCP_004_03_05]
		Redirect to dashboard page when user click cancel button in UPnP page

		When the device was connection and UPnP setting process is waiting
		And the user click "Cancel" link

		Then the user will redirect to dashboard page

	Scenario:  [PCP_004_03_06]
		Disable any button when process of UPnP setting is waiting, except the cancel button

		When the device was connection and UPnP setting process is waiting

		Then the user did not click on the copy button of device, except the cancel button


  Scenario:  [PCP_004_03_07]
  	Redirect to dashborad page when user click cancel on status of UPnP setting is waiting

  	When the device was connection and UPnP setting process is waiting
		And the user click "Cancel" link

		Then the user will redirect to dashboard page


