Feature: [REST_07_02] Check Accepting Status API

  Background:
   Given an device exists
     And an user exists
     And the device paired with the user
     And user has gernerate an invitation key
     And an invitee exists
     And an existing certificate and RSA key
     And user sends a POST request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | VALID INVITATION KEY           |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

  Scenario: [REST_07_02_01]
    The invitee check accepting status successfully.

    When user sends a GET request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | VALID INVITATION KEY           |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "200"
     And the JSON response should be:
      | result | success |

  Scenario: [REST_07_02_02]
    The invitee is failed to check accepting status with missing params.

    When user sends a GET request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | VALID INVITATION KEY           |
      # | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 000                            |
      | description           | Missing required params.       |

  Scenario: [REST_07_02_03]
    The invitee is failed to checking accepting status with invalid invitee cloud id.

    When user sends a GET request to /resource/1/permission with:
      | cloud_id              | INVALID INVITEE CLOUD ID       |
      | invitation_key        | VALID INVITATION KEY           |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 201                            |
      | description           | Invalid cloud id.              |

  Scenario: [REST_07_02_04]
    The invitee is failed to checking accepting status with invalid invitation key.

    When user sends a GET request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | INVALID INVITATION KEY         |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 021                            |
      | description           | Invalid invitation key.        |

  Scenario: [REST_07_02_05]
    The invitee is failed to checking accepting status with invalid signature.

    When user sends a GET request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | VALID INVITATION KEY           |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | INVALID SIGNATURE              |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 101                            |
      | description           | Invalid signature.             |

  Scenario: [REST_07_02_06]
    The invitee is failed to accepts invitation if time out.

    When timeout
     And user sends a GET request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | VALID INVITATION KEY           |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 301                            |
      | description           | Timeout.                       |

  Scenario: [REST_07_02_07]
    The invitee is failed to accepts invitation with some error code feedback.

    When the device returns an error code 571
     And user sends a GET request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | VALID INVITATION KEY           |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 302                            |
      | description           | Failed on creating permission, error code from NAS: 571. |

  Scenario: [REST_07_02_08]
    The invitee is failed to checking accepting status with some other error.

    When the acception succeeds
    When something wrong with some error
     And user sends a GET request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | VALID INVITATION KEY           |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 300                            |
      | description           | Unexpected error.              |
