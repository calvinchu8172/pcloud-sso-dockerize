Feature: [PCP_004_04] Unpairing

	Background:
    Given the user have a paired device
    And the user visits unpairing page

	Scenario:  [PCP_004_04_01]
	  Show warning message and device information

	  Then the user should see "Are you sure" message on unpairing page

	Scenario:  [PCP_004_04_02]
	  Show unpairing message

	  When the user click "Confirm" link

	  Then the user should see "successfully unpaired" message on unpairing page

	Scenario:  [PCP_004_04_03]
		Redirect to dashboard page when user click cancel button on unpairing page

		When the user click "Cancel" link

		Then the user will redirect to dashboard page

	Scenario:  [PCP_004_04_04]
		Redirect to search devices page when user unpairing the device is existed

		When the device is unpaired and the device is existed

		Then the user will redirect to search devices page
		And the user should see the device in search devices page

  Scenario:  [PCP_004_04_05]
  	Redirect to search devices page when user unpairing the device is not existed

  	When the device is unpaired and the device is not existed

  	Then the user will redirect search devices page
  	And the user should not see the device in search devices page

