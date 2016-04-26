Feature: [PCP_001_04] oauth

	Background:
		Given a user visits home page

	Scenario: [PCP_001_04_01]
	  Show error message when permissions error
	    And the user was not a member
		 When the user click sign in with Facebook link and not grant permission
	   Then the user should see oauth feature "Could not authenticate you" message

	Scenario: [PCP_001_04_02]
	  Redirect to Terms of Use page when omniauth user have not agree terms of use
	    And the user was not a member
	   When the user click sign in with Facebook link and grant permission
	   Then the user will redirect to Terms of Use page
	    And the user should see oauth feature "Terms of Use" message

	Scenario: [PCP_001_04_03]
	  Login and redirect to My Devices/Search Devices page
	    And the user was a member
		 When the user click sign in with Facebook link
	   Then the user should login
	    And redirect to My Devices/Search Devices page

	Scenario: [PCP_001_04_04]
		Omniauth user can not change password
		  And the user was a member
		 When the user click sign in with Facebook link
		  And the user visits profile page
		 Then the omniauth user should not see change password link

	Scenario: [PCP_001_04_05]
	    Redirect to Terms of Use page when omniauth user have not agree terms of use, then check and click confirm
	    And the user was not a member
	    When the user click sign in with Facebook link and grant permission
	    Then the user will redirect to Terms of Use page
	    And the user should see oauth feature "Terms of Use" message
	    When the user click Terms of Use page
        # Then user will login and redirect to dashboard
        Then the user will redirect to editing password page

  Scenario:  [PCP_001_04_06]
	    If user doesn't check the box of user agreement terms, the user will see message
	    And the user was not a member
	    When the user click sign in with Facebook link and grant permission
	    Then the user will redirect to Terms of Use page
	    And the user should see oauth feature "Terms of Use" message
        When the user doesn't click Terms of Use page
        Then user will stay in Terms of Use page
        Then the user will see the warning message "Please accept the user agreement terms"
