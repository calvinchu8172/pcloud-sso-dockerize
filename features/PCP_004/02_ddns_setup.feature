@javascript
Feature: [PCP_004_02] DDNS Setup

	Background:
	  Given the user have a paired device
	  And the user visits DDNS setup page

	Scenario Outline:  [PCP_004_02_01]
	  Show error message when hostname invalid
	  And the user filled the invalid Hostname <Hostname>

	  When the user click "Submit" button

	  Then the user should see error message for Hostname

	  Examples:
      | Hostname              																										|
      | hi						        																										|
      | this-is-a-test-hostname-and-we-need-make-this-hostname-over-63-characters |
      | hi@                   																										|
      | 0A0  																																			|

	Scenario:  [PCP_004_02_02]
	  Show error message when hostname exists
		And the user filled the exist Hostname

		When the user click "Submit" button

	  Then the user should see error message for Hostname

	Scenario:  [PCP_004_02_03]
	  Show synchronizing information
	  And the user filled the valid Hostname

	  When the user click "Submit" button

	  Then the user should see "Synchronizing DDNS settings" message on DDNS setup page

	Scenario:  [PCP_004_02_04]
	  Redirect to DDNS setting page when update failed
	  And the user filled the valid Hostname

	  When the user click "Submit" button
	  But the server update DDNS setting failed

	  Then the user should see error message for Hostname

	Scenario:  [PCP_004_02_05]
	  Redirect to success page when hostname update
	  And the user filled the valid Hostname

	  When the user click "Submit" button
	  And the server update DDNS setting successfully

	  Then the user should see success message on DDNS setup page

	Scenario:  [PCP_004_02_06]
	  Redirect to UPnP setup page if device is new one
	  And the user filled the valid Hostname

	  When the user click "Submit" button
	  And the server update DDNS setting successfully

	  Given the device was first setting DDNS after paired

	  When the user click "Confirm" link

	  Then the user will redirect to UPnP setup page


  Scenario Outline: [PCP_004_02_07]
    Test each field length

    When the user filled the user information over length limit
      | Text field        | length limit           |
      | host_name         | 63                     |

    Then the user should see error message for over length limit

    Examples:
      | Text field        |
      | host_name         |

  Scenario:  [PCP_004_02_08]
  	Redirect to profile page when user click cancel button in DDNS page

  	When the user click "Cancel" link

  	Then the user will redirect to dashboard page



