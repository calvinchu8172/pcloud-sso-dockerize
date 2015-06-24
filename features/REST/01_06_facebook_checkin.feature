Feature: Facebook Check In

  Background:
    Given an existing client binding with Facebook

  Scenario: [REST_01_06_01]
    Client check in by valid Facebook

    When client send a GET request to /user/1/checkin/facebook

    Then the response status should be "200"
    And the JSON response should include:
      """
      ["result", "account"]
      """

  Scenario: [REST_01_06_02]
    Client check in by invalid Facebook account

    When client send a GET request to /user/1/checkin/facebook

    Then the response status should be "400"
    And the JSON response should include error code: "000"
    And the JSON response should include description: "Invalid Facebook account"

  Scenario: [REST_01_06_03]
    Client check in by unregistered account

    When client send a GET request to /user/1/checkin/facebook

    Then the response status should be "400"
    And the JSON response should include error code: "001"
    And the JSON response should include description: "unregistered"


  Scenario: [REST_01_06_04]
    Client check in by not binding account

    When client send a GET request to /user/1/checkin/facebook

    Then the response status should be "400"
    And the JSON response should include error code: "000"
    And the JSON response should include description: "not binding yet"
