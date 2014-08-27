@javascript
Feature: [PCP_003_03] Pairing

	Background:
	  Given a user visit pairing page

	Scenario:  [PCP_003_03_01]
	  Show check information on first step

	  Then the user should see "Are you sure" message on pairing page

	Scenario:  [PCP_003_03_02]
	  Show countdown and pairing information when pairing start

	  When the user pairing is start
		Then the user should see the countdown and pairing information

	Scenario:  [PCP_003_03_03]
	  Show "Device is not found" message when device was not connection

	  When the user pairing is not connection
	  Then the user should see "Device is not found" message on pairing page


	Scenario:  [PCP_003_03_04]
	  Show timeout information

	  When the user pairing is timeout
	  Then the user should see "Pairing timeout." message on pairing page

	Scenario:  [PCP_003_03_05]
	  Show paired information and redirect to DDNS setting page when click confirm button

	  When the user pairing is finished
	  Then the user should see "Successfully paired." message on pairing page
	  When the user click confirm button when finished pairing
	  Then the user will redirect to personal page