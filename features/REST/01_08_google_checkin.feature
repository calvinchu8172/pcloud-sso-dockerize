Feature: Google Checkin

  Background:

    Given the client has access token and uuid from google
    And an existing certificate and RSA key

  Scenario:
    Client sign in by google uuid and access token with binding account

    Given client has registered in Rest API by google account
    And this account is already binding to "google_auth2"

    When client send a GET request to /user/1/checkin/google with:
    | user_id      | USER ID      |
    | access_token | ACCESS TOKEN |

    Then the response status should be "200"
    And the JSON response should include:
      """
      ["result", "account"]
      """

  Scenario:
    Client sign in by google uuid and access token with binding account

    Given client has registered in Rest API by google account
    And this account is already binding to "google_auth2"

    When client send a GET request to /user/1/checkin/google with:
    | user_id      | INVALID USER ID      |
    | access_token | INVALID ACCESS TOKEN |

    Then the response status should be "400"
    And the JSON response should include error code: "000"
    And the JSON response should include description: "Invalid Facebook account"

  Scenario:
    Client sign in by google uuid and access token but not registered yet

    When client send a GET request to /user/1/checkin/google with:
    | user_id      | USER ID      |
    | access_token | ACCESS TOKEN |

    Then the response status should be "400"
    And the JSON response should include error code: "001"
    And the JSON response should include description: "unregistered"

  Scenario:
    Client sign in by google uuid and access token but not binding account yet

    Given client has registered in Rest API by google account

    When client send a GET request to /user/1/checkin/google with:
    | user_id      | USER ID      |
    | access_token | ACCESS TOKEN |

    Then the response status should be "400"
    And the JSON response should include error code: "002"
    And the JSON response should include description: "not binding yet"

  Scenario:
    Client sign in by google uuid and access token but not binding account yet

    Given client has registered in Rest API by google account
    And this account is already binding to "google_auth2"
    And client already has a portal account

    When client send a GET request to /user/1/checkin/facebook with:
    | user_id      | USER ID      |
    | access_token | ACCESS TOKEN |

    Then the response status should be "400"
    And the JSON response should include error code: "003"
    And the JSON response should include description: "not have password"
