@javascript
Feature: [PCP_004_03_02] UPnP Setup Version 2
	Background:
    Given a user visit UPnP setup page with module version 2 device
	    And the page will waiting for connection with device

	Scenario: [PCP_004_03_02_01]
	  Show synchronizing information
	   Then the user should see "Synchronizing UPnP settings... " message on UPnP setup page

	Scenario: [PCP_004_03_02_02]
	  Show "Device is not found" message when device was not connection
	   When the device was offline
	   Then the user should see "Device is not found" message on UPnP setup page

	Scenario: [PCP_004_03_02_03]
	  Show device information and service list
	   When the device was online the device will response service list
	   Then the user should see service list

	Scenario: [PCP_004_03_02_04]
	  Show success information when update successfully
	   When the device was online the device will response service list
	    And the user changed UPnP setting
	   When the user click "Submit" button
	    And the services was success updated
	   Then the user should see "UPnP settings have been successfully updated." message on UPnP setup page
	    And the user click "Confirm" link
	   Then the user will redirect to My Devices page

	Scenario: [PCP_004_03_02_05]
		Redirect to My Devices page when user completely cancel the UPnP setup flow
		 When the user click "Cancel" button
		 Then the user will see the confirm message about cancel UPnP setup
		 When the user click "Confirm" link
		 Then the user will redirect to My Devices page after cancel

	Scenario:	[PCP_004_03_02_06]
		The UPnP setup should continue when user click cancel but the user want to go back to setup flow
		 When the user click "Cancel" button
		 Then the user will see the confirm message about cancel UPnP setup
		 When the user click "Cancel" button
		 Then the user will go back to setup flow

	Scenario: [PCP_004_03_02_07]
		Disable any button when process of UPnP setting is waiting, except the cancel button
		 When the user want to click link without cancel
		 Then it should not do anything on UPnP setup page

  Scenario: [PCP_004_03_02_08]
    Show port number of each service when user click "Show Service Port"
     When user click "Show Service Port"
     Then user should see port numbers of each service
      And the "Show Service Port" button should be replaced by "Hide Service Port" button

	Scenario: [PCP_004_03_02_09]
	  Renew the port numbers between 6000 and 10000 for those disabled services in service list and the port numbers should not in the used wan port list
	   When the device was online the device will response service list with used wan port list
	   Then the port number of all disabled service will be given a random number between 6000 and 10000
  	  And those port numbers should not in the used wan port list

	Scenario: [PCP_004_03_02_10]
	  Show "Failure" text in the "Update Result" column when the service update failed
	   When the device was online the device will response service list
	    And the user changed UPnP port setting of a disabled service
	    And the user clicked the checkbox to enabled the service
	    And the user click "Submit" button
	   Then the user should see "Synchronizing UPnP settings... " message on UPnP setup page
	    And the session status now should be "submit"
	   When device response the failure result of the modified service
		  And the upnp session flow should starting reload service list from device
		 When the device was online the device will response service list
		  And the user should see "Failure" text in "Update Result" column of the service on UPnP setup page
		  And the checkbox value of the service should be "true"
		  And the status value of the service should be "false"

	Scenario: [PCP_004_03_02_11]
	  Show "Success" text in the "Update Result" column when the service update successfully
	   When the device was online the device will response service list
	    And the user changed UPnP port setting of a disabled service
	    And the user clicked the checkbox to enabled the service
	    And the user click "Submit" button
	   Then the user should see "Synchronizing UPnP settings... " message on UPnP setup page
	    And the session status now should be "submit"
	   When device response the success result of the modified service
	    And the session status now should be "updated"
	   Then the user should see "Success" text in "Update Result" column of the service on UPnP setup page
	    And the checkbox value of the service should be "true"
		  And the status value of the service should be "true"
