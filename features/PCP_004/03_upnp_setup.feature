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
    Show port number of each service when user click "Show Service Port"

    And user click "Show Service Port"

    Then user should see port numbers of each service

    And the "Show Service Port" button should be replaced by "Hide Service Port" button



	Scenario: [PCP_004_03_05]
	  Renew the port numbers between 1025 and 65535 for those disabled services in service list and the port numbers should not in the used wan port list

	  And the page will waiting for connection with device

	  When the device was online the device will response other service list
	  # And Some services in the list were disabled
	  # And Some wan_port is duplicate with the port in used_wan_port_list

	  Then the port number of all disabled service will be given a random number between 1025 and 65525
	  And those port numbers should not in the used wan port list


	Scenario: [PCP_004_03_06]
	  Show "Failure" text in the "Update Result" column when the service update failed

	  And the page will waiting for connection with device

	  When the device was online the device will response service list

	  Given the user changed UPnP port setting of a disabled service
	  And the user clicked the checkbox to enabled the service

	  When the user click "Submit" button
	  Then the user should see "Synchronizing UPnP settings... " message on UPnP setup page

	  And the session status now should be "submit"

		And the session status should be "reload"
		And the session status should be updated to "start"

	  When the device was online the device will response the new service list


	  # Then the user should see service list

	  # Then the user should see "Failure" text in "Update Result" column of the service on UPnP setup page
	  And the checkbox of the service should be unchecked



	# Scenario: [PCP_004_03_07]
	#   Show "Success" text in the "Update Result" column when the service update successfully

	#   And the page will waiting for connection with device

	#   When the device was online the device will response service list

	#   Given the user changed UPnP port setting of a disabled service
	#   And the user clicked the checkbox to enabled the service

	#   When the user click "Submit" button
	#   And the service was updated successfully

	#   Then the user should see "Success" text in "Update Result" column of the service on UPnP setup page
	#   And the checkbox of the service should be checked


	Scenario: [PCP_004_03_08]
	  Show success information when update successfully
	  And the page will waiting for connection with device

	  When the device was online the device will response service list

	  Given the user changed UPnP setting

	  When the user click "Submit" button
	  And the services was success updated

	  Then the user should see "UPnP settings have been successfully." message on UPnP setup page
	  And the user click "Confirm" link

	  Then the user will redirect to My Devices page



	Scenario: [PCP_004_03_09]
		Redirect to My Devices page when user completely cancel the UPnP setup flow
	  And the page will waiting for connection with device

		When the user click "Cancel" button

		Then the user will see the confirm message about cancel UPnP setup

		When the user click "Confirm" link

		Then the user will redirect to My Devices page after cancel



	Scenario:	[PCP_004_03_10]
		The UPnP setup should continue when user click cancel but the user want to go back to setup flow
		And the page will waiting for connection with device

		When the user click "Cancel" button

		Then the user will see the confirm message about cancel UPnP setup

		When the user click "Cancel" button

		Then the user will go back to setup flow

	Scenario: [PCP_004_03_11]
		Disable any button when process of UPnP setting is waiting, except the cancel button
		And the page will waiting for connection with device

		When the user want to click link without cancel

		Then it should not do anything on UPnP setup page