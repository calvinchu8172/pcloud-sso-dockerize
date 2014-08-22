Feature: [PCP_001_04] oauth

	Background: 
		Given a user visit home page

	Scenario:  [PCP_001_04_01]
	  Show error message when permissions error

	  When the user click oauth link and no premission
	  Then the user should see oauth feature "Could not authenticate you" message

	Scenario:  [PCP_001_04_02]
	  Redirect to Terms of Use page when omniauth user have not agree terms of use

	  When the user click oauth link and pass premission
	  Then the user will redirect to Terms of Use page
	  And the user should see oauth feature "Terms of Use" message
	  
	Scenario:  [PCP_001_04_03]
	  Login and redirect to dashborad/search devices page.
	  
	  When the user click oauth link and pass premission
	  Then the user will redirect dashborad/search devices page.