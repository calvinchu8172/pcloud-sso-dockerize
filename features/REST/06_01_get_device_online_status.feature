Feature: [REST_06_01] Get Device Online Status

  Background:
   Given an device exists
     # And there is a NAS paired with user
     And an existing certificate and RSA key


  Scenario: [REST_06_01_01]
    If there is a device in database, user gets device online status successfully.

    # Given there is no vendor device in database
      # And the ASI server return valid result
    When user sends a GET request to /device/1/online_status with:
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | device_id             | VALID DEVICE ID                |
      | signature             | VALID SIGNATURE                |

    # Then there is vendor device data in database
    Then the response status should be "200"
     And the JSON response should include:
      """
      ["device_id", "online_status"]
      """

  Scenario: [REST_06_01_02]
    If user gets device online status with missing params, user will see error message.

    # Given there is no vendor device in database
      # And the ASI server return valid result
    When user sends a GET request to /device/1/online_status with:
      # | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | device_id             | VALID DEVICE ID                |
      | signature             | VALID SIGNATURE                |

    # Then there is vendor device data in database
    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 000                            |
      | description           | Missing required params.       |

  Scenario: [REST_06_01_03]
    If user gets device online status with invalid device id, user will see error message.

    # Given there is no vendor device in database
      # And the ASI server return valid result
    When user sends a GET request to /device/1/online_status with:
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | device_id             | INVALID DEVICE ID              |
      | signature             | VALID SIGNATURE                |

    # Then there is vendor device data in database
    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 004                            |
      | description           | Invalid device.                |

  Scenario: [REST_06_01_04]
    If user gets device online status with invalid signature, user will see error message.

    # Given there is no vendor device in database
      # And the ASI server return valid result
    When user sends a GET request to /device/1/online_status with:
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | device_id             | VALID DEVICE ID                |
      | signature             | INVALID SIGNATURE              |

    # Then there is vendor device data in database
    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 101                            |
      | description           | Invalid signature.             |


  Scenario: [REST_06_01_05]
    If user gets device online status with invalid signature, user will see error message.

    # Given there is no vendor device in database
     And something wrong when render result
    When user sends a GET request to /device/1/online_status with:
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | device_id             | VALID DEVICE ID                |
      | signature             | VALID SIGNATURE                |

    # Then there is vendor device data in database
    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 300                            |
      | description           | Unexpected error.              |
