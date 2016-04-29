Feature: [ASI_01] get vendor device list

  Background:
   Given an user exists
     And there is a NAS paired with user
     And an existing certificate and RSA key


  Scenario: [ASI_01_01_01]
    If there is no vendor device in database, user get vendor device list from ASI server.

    Given there is no vendor device in database
      And the ASI server return valid result
     When NAS send a GET request to /resource/1/vendor_devices with:
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then there is vendor device data in database
     And the response status should be "200"
     And the JSON response should include:
      """
      ["cloud_id", "device_list"]
      """
      # """
      # ["cloud_id", "device_list", "device_name", "serial_number", "meta"]
      # """
  Scenario: [ASI_01_01_02]
    If there is an existing vendor device in database, and has not updated in 10 minutes. the vendor device will not be updated.

    # Given there is no vendor device in database
    Given there is an existed vendor device in database
      And the ASI server return valid result
     When NAS send a GET request to /resource/1/vendor_devices with:
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then there is vendor device data in database
     And the updated time will keep the same
     And the response status should be "200"
     And the JSON response should include:
      """
      ["cloud_id", "device_list"]
      """
  Scenario: [ASI_01_01_03]
    If there is an existing vendor device in database, and has not updated in 10 minutes. the vendor device will be updated.

    # Given there is no vendor device in database
    Given there is an existed vendor device in database
      And the vendor device has updated more then 10 minutes
      And the ASI server return valid result
     When NAS send a GET request to /resource/1/vendor_devices with:
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then there is vendor device data in database
    And the updated time will be updated
     And the response status should be "200"
     And the JSON response should include:
      """
      ["cloud_id", "device_list"]
      """

  Scenario: [ASI_01_02]
    If there is no vendor device in database, user get vendor device list from ASI server with invalid certificate serial.

    Given there is no vendor device in database
      And the ASI server return valid result
     When NAS send a GET request to /resource/1/vendor_devices with:
      | certificate_serial    | INVALID CERTIFICATE SERIAL     |
      | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
    And the JSON response should include the error:
      | error_code            | 101                            |
      | description           | invalid signature.             |


  Scenario: [ASI_01_03]
    If there is no vendor device in database, user get vendor device list from ASI server with invalid cloud id.

    Given there is no vendor device in database
      And the ASI server return valid result
     When NAS send a GET request to /resource/1/vendor_devices with:
      | certificate_serial    | CERTIFICATE SERIAL             |
      | cloud_id              | INVALID CLOUD ID               |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
    And the JSON response should include the error:
      | error_code            | 201                            |
      | description           | invalid cloud id or token.     |

  Scenario: [ASI_01_04]
    If there is no vendor device in database, user get vendor device list from ASI server with missing params.

    Given there is no vendor device in database
      And the ASI server return valid result
     When NAS send a GET request to /resource/1/vendor_devices with:
      # | certificate_serial    | CERTIFICATE SERIAL             |
      | cloud_id              | INVALID CLOUD ID               |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      # | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
    And the JSON response should include the error:
      | error_code            | 000                            |
      | description           | Missing required params.       |

  Scenario: [ASI_01_05]
    If there is no vendor device in database, user get vendor device list from ASI server with invalid cloud id.

    Given there is no vendor device in database
      And the ASI server return valid result
     When NAS send a GET request to /resource/1/vendor_devices with:
      | certificate_serial    | CERTIFICATE SERIAL             |
      | cloud_id              | INVALID CLOUD ID               |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
    And the JSON response should include the error:
      | error_code            | 201                            |
      | description           | invalid cloud id or token.     |

  Scenario: [ASI_01_06]
    If there is no vendor device in database, user get vendor device list from ASI server with unpaired NAS.

    Given there is no vendor device in database
      And the NAS is not paired with user
      And the ASI server return valid result
     When NAS send a GET request to /resource/1/vendor_devices with:
      | certificate_serial    | CERTIFICATE SERIAL             |
      | cloud_id              | CLOUD ID                       |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
    And the JSON response should include the error:
      | error_code            | 004                            |
      | description           | invalid device.                |


  Scenario: [ASI_01_07]
    If there is no vendor device in database, user get vendor device list from ASI server with no this NAS.

    Given there is no vendor device in database
      And there is no this NAS corresponding to the mac_address and serial_number
      And the ASI server return valid result
     When NAS send a GET request to /resource/1/vendor_devices with:
      | certificate_serial    | CERTIFICATE SERIAL             |
      | cloud_id              | CLOUD ID                       |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
    And the JSON response should include the error:
      | error_code            | 004                            |
      | description           | invalid device.                |

  Scenario: [ASI_01_08]
    If there is no vendor device in database, user get vendor device list from ASI server with something wrong.

    Given there is no vendor device in database
      And the ASI server return invalid result
     When NAS send a GET request to /resource/1/vendor_devices with:
      | certificate_serial    | CERTIFICATE SERIAL             |
      | cloud_id              | CLOUD ID                       |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
    And the JSON response should include the error:
      | error_code            | 300                            |
      | description           | Unexpected error.              |



