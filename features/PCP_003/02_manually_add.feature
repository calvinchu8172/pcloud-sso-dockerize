Feature: [PCP_003_02] Manually Add

	Background: 
	  Given a user visit Manually Add page

	Scenario:  [PCP_003_02_01]
	  Show error messages when mac address invalid

	  When the user filled the invalid Mac Address
	  And the user filled the "Serial Number"
	  And the user click "Submit"

	  Then the user should see manually add feature "is invalid" message

	Scenario:  [PCP_003_02_02]
	  Show error messages when device not found

	  When the user filled the valid Mac Address
	  And the user filled the incorrect Serial Number
	  And the user click "Submit"

	  Then the user should see manually add feature "is invalid" message

	Scenario:  [PCP_003_02_03]
	  Redirect to pairing page when device connecting 
	  
	  When the user filled the valid Mac Address
	  And the user filled the correct Serial Number
	  And the user click "Submit"

	  Then the user should see manually add feature pairing success message
