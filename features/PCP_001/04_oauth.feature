Feature: [PCP_001_04] oauth

	Background:
		Given a user visits home page

		When the user click sign in with Facebook link

	Scenario:  [PCP_001_04_01]
	  Show error message when permissions error

	  And the user did not grant permission

	  Then the user should see oauth feature "Could not authenticate you" message

	Scenario:  [PCP_001_04_02]
	  Redirect to Terms of Use page when omniauth user have not agree terms of use

	  And the user grant permission

	  Then the user will redirect to Terms of Use page
	  And the user should see oauth feature "Terms of Use" message

	Scenario:  [PCP_001_04_03]
	  Login and redirect to dashborad/search devices page

	  And the user grant permission

	  Then the user should login
	  And redirect to dashboard/search devices page

	Scenario: [PCP_001_04_04]
	  Redirect to login page when user disagree omniauth agreement

	  When the user disagree omniauth agreement

	  Then the user will redirect to login page

	Scenario: [PCP_001_04_05]
		Show error message when omniauth user reset password

		When the omniauth user want to reset password

		Then the user should see oauth feature "not found" message

	Scenario: [PCP_001_04_06]
		Omniauth user can not change password

		When the omniauth user want to change password

		Then the omniauth user should not see change password button in profile

