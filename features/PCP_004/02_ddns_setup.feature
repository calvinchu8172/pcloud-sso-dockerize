@javascript
Feature: [PCP_004_02] DDNS Setup

	Background:
	  Given a user register a device
	  Then the user finished the pairing
	  Then the user visit ddns setup page

	Scenario:  [PCP_004_02_01]
	  Show error message when hostname invalid

	  When the user filled the invalid hostname
	  Then the user should see hostname "invalid" error message

	Scenario:  [PCP_004_02_02]
	  Show error message when hostname exists

		When the user filled the registered hostname
	  Then the user should see hostname "is exist. Please try another" error message

	Scenario:  [PCP_004_02_03]
	  Show synchronizing information

	  When the user filled the valid hostname
	  Then the user should see ddns feature "Synchronizing DDNS settings..." message

	Scenario:  [PCP_004_02_04]
	  Redirect to DDNS setting page when update failed

	  When the user update ddns setting failed
	  Then the user should see hostname "Update failed. Please try again later." error message

	Scenario:  [PCP_004_02_05]
	  Redirect to success page when hostname update

	  When the user update ddns setting success
	  Then the user should see ddns feature success message

	Scenario:  [PCP_004_02_06]
	  Redirect to UPnP setup page if device is new one

	  When the user have new device and finished ddns setting
	  Then the user click confirm in ddns setting
	  Then the user will redirect to upnp setup page
