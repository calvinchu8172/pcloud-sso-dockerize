Feature: [PCP_004_02] DDNS Setup

	Background: 
	  Given a user visit device DDNS page

	Scenario:  [PCP_004_02_01]
	  Show error message when hostname invalid

	  When the user filled the "hostName" <zyxel>
	  And the user click "Submit"
	  The the user should see "is exist. Please try another"

	Scenario:  [PCP_004_02_02]
	  Show error message when hostname exists

	  When the user regist the "hostname" <hello>
	  Then the user visit device DDNS page
	  And the user filled the "hostName" <hello>
	  And the user click "Submit"
	  The the user should see "is exist. Please try another"

	Scenario:  [PCP_004_02_03]
	  Show synchronizing information

	  When the user filled the "hostName" <hello>
	  And the user click "Submit"
	  The the user should see "Synchronizing DDNS settings..."

	Scenario:  [PCP_004_02_04]
	  Redirect to DDNS setting page when update failed

	  When the user filled the "hostName" <fail>
	  And the user click "Submit"
	  Then the user will redirect to "/ddns/setting/"
	  The the user should see "Update failed. Please try again later."
	  
	Scenario:  [PCP_004_02_05]
	  Redirect to success page when hostname update

	  When the user filled the "hostName" <success>
	  And the user click "Submit"
	  Then the user should see "DDNS settings have been successfully."
	  
	Scenario:  [PCP_004_02_06]
	  Redirect to UPnP setup page if device is new one

	  When the user filled the "hostName" <success>
	  And the user click "Submit"
	  Then the user will redirect to "/upnp/"
