@javascript
Feature: [PCP_003_03] Pairing

	Background:
	  Given a user choose a device
	  And the user will redirect to pairing page

	Scenario:  [PCP_003_03_01]
	  Show check information on first step

	  Then the user should see "Are you sure" message on pairing page

	Scenario:  [PCP_003_03_02]
	  Show countdown and pairing information when pairing start

	  When the user click "Confirm" button to start pairing flow

		Then the user should see "Connecting" message on pairing page

		When the device was connection

		Then the user should see the pairing information

	Scenario:  [PCP_003_03_03]
	  Show "Device is not found" message when device was not connection

	  When the user click "Confirm" button to start pairing flow
	  But the device was not connection

	  Then the user should see "Device is not found" message on pairing page


	Scenario:  [PCP_003_03_04]
	  Show timeout information

	  When the user click "Confirm" button to start pairing flow

	  Then the user should see "Connecting" message on pairing page

		When the device was connection
		But the user didn't click on the copy button of device within 10 minutes

	  Then the user should see "Pairing has been canceled" message on pairing page

	Scenario:  [PCP_003_03_05]
	  Show paired information and redirect to DDNS setting page when click confirm button

	  When the user click "Confirm" button to start pairing flow
	  And the user click the copy button of device within 10 minutes

	  Then the user should see "Successfully paired." message on pairing page

	  When the user click "Confirm" button when finished pairing
	  Then the user will redirect to DDNS setup page