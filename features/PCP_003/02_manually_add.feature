Feature: [PCP_003_02] Manually Add

	Background: 
	  Given a user visit manually add page

	Scenario:  [PCP_003_02_01]
	  Show error messages when mac address invalid

	  When the user filled the invalid mac address
	  And the user click "Submit" button

	  Then the user should see mac address error message
  
	Scenario:  [PCP_003_02_02]
	  Show error messages when device not found

	  When the user filled the not exists device information
	  And the user click "Submit" button

	  Then the user should see manually add feature error message

	Scenario:  [PCP_003_02_03]
	  Redirect to pairing page when device connecting 
	  
		When the user filled the exists device information
	  And the user click "Submit" button

	  Then the user will redirect to pairing check page
