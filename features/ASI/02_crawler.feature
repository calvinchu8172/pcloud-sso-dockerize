Feature: [ASI_02] crawler

  Background:
   Given an user exists

  Scenario: [ASI_02_01_01]
    If there is an existing vendor device in database, and has not updated in 10 minutes. the vendor device will not be updated.

    # Given there is no vendor device in database
    Given there is an existed vendor device in database
      And the ASI server return valid result
     When NAS send a GET request to /resource/1/vendor_devices/crawl with:
     Then there is vendor device data in database
      And the updated time will keep the same
      And the response status should be "200"
      And the JSON response should include:
       """
       ["result", "device_list"]
       """
   Scenario: [ASI_02_01_02]
    If there is an existing vendor device in database, and has not updated in 10 minutes. the vendor device will be updated.

    # Given there is no vendor device in database
    Given there is an existed vendor device in database
      And the vendor device has updated more then 10 minutes
      And the ASI server return valid result
     When NAS send a GET request to /resource/1/vendor_devices/crawl with:
     Then there is vendor device data in database
      And the updated time will be updated
      And the response status should be "200"
      And the JSON response should include:
       """
       ["result", "device_list"]
       """

  Scenario: [ASI_02_01_03]
    If there is no vendor device in database, user get vendor device list from ASI server with something wrong.

    Given there is an existed vendor device in database
      And the vendor device has updated more then 10 minutes
      And the ASI server return invalid result
     When NAS send a GET request to /resource/1/vendor_devices/crawl with:
     Then the response status should be "400"
      And the JSON response should include the error:
       | error_code            | 300                            |
       | description           | Unexpected error.              |


