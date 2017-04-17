Feature: [REST_01] Device Authentication API

  Background:
    Given an device exists
      And an user exists
      And the device paired with the user
      And an client app exists
      And an existing certificate and RSA key

  Scenario: [REST_01_01]
    Device asks Access Token successfully.

    When device sends a POST request to "/d/oauth/authorize" with:
      | app_id                | VALID APP ID                   |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "200"
    And the JSON response should include access_token and refresh_token:
      | access_token | xxxxxxxxxx |
      | refresh_token| xxxxxxxxxx |

  Scenario: [REST_01_02]
    Device fails to ask Access Token if certificate serial is empty.

    When device sends a POST request to "/d/oauth/authorize" with:
      | app_id                | VALID APP ID                   |
      # | certificate_serial    | INVALID CERTIFICATE SERIAL     |
      | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include error code: "400.2"
     And the JSON response should include error message: "Missing Required Parameter: certificate_serial"

  Scenario: [REST_01_03]
    Device fails to ask Access Token if certificate serial is invalid.

    When device sends a POST request to "/d/oauth/authorize" with:
      | app_id                | VALID APP ID                   |
      | certificate_serial    | INVALID CERTIFICATE SERIAL     |
      | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include error code: "400.3"
     And the JSON response should include error message: "Invalid certificate_serial"


  Scenario: [REST_01_04]
    Device fails to ask Access Token if signature is invalid.

    When device sends a POST request to "/d/oauth/authorize" with:
      | app_id                | VALID APP ID                   |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | INVALID SIGNATURE              |

    Then the response status should be "400"
     And the JSON response should include error code: "400.1"
     And the JSON response should include error message: "Invalid signature"

  Scenario: [REST_01_05]
    Device fails to ask Access Token if app_id is empty.

    When device sends a POST request to "/d/oauth/authorize" with:
      # | app_id                | VALID APP ID                   |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include error code: "400.4"
     And the JSON response should include error message: "Missing Required Parameter: app_id"

  Scenario: [REST_01_06]
    Device fails to ask Access Token if cloud_id is empty.

    When device sends a POST request to "/d/oauth/authorize" with:
      | app_id                | VALID APP ID                   |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      # | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include error code: "400.24"
     And the JSON response should include error message: "Missing Required Parameter: cloud_id"

  Scenario: [REST_01_07]
    Device fails to ask Access Token if mac address is empty.

    When device sends a POST request to "/d/oauth/authorize" with:
      | app_id                | VALID APP ID                   |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | cloud_id              | VALID CLOUD ID                 |
      # | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include error code: "400.21"
     And the JSON response should include error message: "Missing Required Parameter: mac_address"

  Scenario: [REST_01_08]
    Device fails to ask Access Token if serial number is empty.

    When device sends a POST request to "/d/oauth/authorize" with:
      | app_id                | VALID APP ID                   |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | VALID MAC ADDRESS              |
      # | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include error code: "400.22"
     And the JSON response should include error message: "Missing Required Parameter: serial_number"

  Scenario: [REST_01_09]
    Device fails to ask Access Token if app_id is invalid.

    When device sends a POST request to "/d/oauth/authorize" with:
      | app_id                | INVALID APP ID                 |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include error code: "400.5"
     And the JSON response should include error message: "Invalid app_id"

  Scenario: [REST_01_10]
    Device fails to ask Access Token if mac_address is invalid.

    When device sends a POST request to "/d/oauth/authorize" with:
      | app_id                | VALID APP ID                   |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | INVALID MAC ADDRESS            |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include error code: "400.23"
     And the JSON response should include error message: "Device Not Found"

  Scenario: [REST_01_11]
    Device fails to ask Access Token if serial_number is invalid.

    When device sends a POST request to "/d/oauth/authorize" with:
      | app_id                | VALID APP ID                   |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | INVALID SERIAL NUMBER          |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include error code: "400.23"
     And the JSON response should include error message: "Device Not Found"

  Scenario: [REST_01_12]
    Device fails to ask Access Token if both mac_address and serial_number is invalid.

    When device sends a POST request to "/d/oauth/authorize" with:
      | app_id                | VALID APP ID                   |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | INVALID MAC ADDRESS            |
      | serial_number         | INVALID SERIAL NUMBER          |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include error code: "400.23"
     And the JSON response should include error message: "Device Not Found"

  Scenario: [REST_01_13]
    Device fails to ask Access Token if cloud_id is invalid.

    When device sends a POST request to "/d/oauth/authorize" with:
      | app_id                | VALID APP ID                   |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | cloud_id              | INVALID CLOUD ID               |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include error code: "400.25"
     And the JSON response should include error message: "Invalid cloud_id"

  Scenario: [REST_01_13]
    Device fails to ask Access Token if device is not paired.

    When the device is not paired
    When device sends a POST request to "/d/oauth/authorize" with:
      | app_id                | VALID APP ID                   |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | cloud_id              | VALID CLOUD ID                 |
      | mac_address           | VALID MAC ADDRESS              |
      | serial_number         | VALID SERIAL NUMBER            |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include error code: "403.0"
     And the JSON response should include error message: "User Is Not Device Owner"



