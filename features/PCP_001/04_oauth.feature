Feature: [PCP_001_04] oauth

	Background: 
		Given a user visit home page

	Scenario:  [PCP_001_04_01]
	  Show error message when permissions error

	Scenario:  [PCP_001_04_02]
	  Redirect to Terms of Use page when omniauth user have not agree terms of use
	  
	Scenario:  [PCP_001_04_03]
	  Login and redirect to dashborad/search devices page.
	  
