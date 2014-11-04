Feature: REST API testing

  Background:
	  Given the device with information
	    | mac_address      | 099789665701                                             |
	    | serial_number    | A123456                                                  |
	    | model_name       | NSA325                                                   |
	    | firmware_version | 1.0                                                      |
	    | algo             | 1                                                        |
	    | signature        | 206920dac685455b4d0615555d1bfe0788c3e659a4e432c2ef7e1659 |

	Scenario: [REST-01]
		Check standard device registration process

	  When the device POST to "/d/1/register"
	  Then the HTTP should return 200
	  And the record in databases as expected

	Scenario: [REST-02]
		Check device update process when "firmware_version" was be changed

		When the device already registration
		But the device "firmware_version" was be changed to "2.0"
		Then the HTTP should return 200
		And the record in databases as expected

	Scenario: [REST-03]
		Check device update process when "serial_number" was be changed

		When the device already registration
		But the device "serial_number" was be changed to "654321A"
		Then the HTTP should return 200
		And the record in databases as expected

	Scenario: [REST-04]
		Check device update process when "mac_address" was be changed

		When the device already registration
		But the device "mac_address" was be changed to "000000000000"
		Then the HTTP should return 200
		And the record in databases as expected

	Scenario: [REST-05]
		Check device update process when "signature" is not correct

		When the device signature was be changed to "000000000000"
		Then the HTTP should not return 200 and get json error code "Failure"

	Scenario: [REST-06]
		Check device update process when "mac_address" is not correct

		When the device "mac_address" was be changed to "@@@@@@@@@@"
		Then the HTTP should not return 200 and get json result code "invalid parameter"

	Scenario: [REST-07]
		Check device update process when "serial_number" is null

		When the device "serial_number" was be changed to ""
		Then the HTTP should not return 200 and get json result code "invalid parameter"