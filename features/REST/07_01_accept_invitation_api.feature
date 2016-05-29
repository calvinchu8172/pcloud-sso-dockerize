Feature: [REST_07_01] Accept Invitation API

  Background:
   Given an device exists
     And an user exists
     And the device paired with the user
     And user has gernerate an invitation key
     And an invitee exists
     And an existing certificate and RSA key

  Scenario: [REST_07_01_01]
    The invitee accepts invitation successfully.

    When user sends a POST request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | VALID INVITATION KEY           |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "200"
    # Then the response status should be "400"
     And the JSON response should be:
      | message | Trying to create permission. Now please request the Check Accepting Status API to check if permission is created.|

  Scenario: [REST_07_01_02]
    The invitee is failed to accepts invitation with missing params.

    When user sends a POST request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | VALID INVITATION KEY           |
      # | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 000                            |
      | description           | Missing required params.       |

  Scenario: [REST_07_01_03]
    The invitee is failed to accepts invitation with invalid invitee cloud id.

    When user sends a POST request to /resource/1/permission with:
      | cloud_id              | INVALID INVITEE CLOUD ID       |
      | invitation_key        | VALID INVITATION KEY           |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 201                            |
      | description           | Invalid cloud id.              |

  Scenario: [REST_07_01_04]
    The invitee is failed to accepts invitation with invalid invitation key.

    When user sends a POST request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | INVALID INVITATION KEY         |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 021                            |
      | description           | Invalid invitation key.        |

  Scenario: [REST_07_01_05]
    The invitee is failed to accepts invitation if the invitation key expire count is 0.

    When the invitation key expire count is 0
     And user sends a POST request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | VALID INVITATION KEY           |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 021                            |
      | description           | Invalid invitation key.        |

  Scenario: [REST_07_01_06]
    The invitee is failed to accepts invitation if the device is not paired to user.

    When the device is unpaired
     And user sends a POST request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | VALID INVITATION KEY           |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 021                            |
      | description           | Invalid invitation key.        |

  Scenario: [REST_07_01_07]
    The invitee cannot accept his own invitation. In other words, the invitee and the user are the same person.

    When user sends a POST request to /resource/1/permission with:
      | cloud_id              | VALID USER CLOUD ID            |
      | invitation_key        | VALID INVITATION KEY           |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 021                            |
      | description           | Invalid invitation key.        |

  Scenario: [REST_07_01_08]
    The invitee is failed to accepts invitation if the invitation is accepted before.

    When the invitaion is accepted before
     And user sends a POST request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | VALID INVITATION KEY           |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 021                            |
      | description           | Invalid invitation key.        |

  Scenario: [REST_07_01_09]
    The invitee is failed to accepts invitation with invalid signature.

    When user sends a POST request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | VALID INVITATION KEY           |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | INVALID SIGNATURE              |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 101                            |
      | description           | Invalid signature.             |

  Scenario: [REST_07_01_10]
    The invitee is failed to accepts invitation with some other error.

    When something wrong when set session or other error
     And user sends a POST request to /resource/1/permission with:
      | cloud_id              | VALID INVITEE CLOUD ID         |
      | invitation_key        | VALID INVITATION KEY           |
      | certificate_serial    | VALID CERTIFICATE SERIAL       |
      | signature             | VALID SIGNATURE                |

    Then the response status should be "400"
     And the JSON response should include the error:
      | error_code            | 300                            |
      | description           | Unexpected error.              |

