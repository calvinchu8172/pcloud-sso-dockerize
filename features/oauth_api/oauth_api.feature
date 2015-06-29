Feature: Oauth API

  Background:
    Given a user sign in from APP
    And the user having access token and uuid from Facebook
    And the user having password <abc12345>
    And the user using valid authentication token

  Scenario Outline: [REST_01_06_01]
    Standard oauth api registration flow

    When the device send information to <account> oauth register API
    Then the API should return "001" error code and "unregistered" message

    When the device send information to <account> oauth register API
    Then the API should return user token message

    Examples:
    | account  |
    | facebook |
    | google   |

  Scenario Outline: [REST_01_06_02]
    Check the APP user wants to checkin by Oauth

    Given the user having APP account from <account> already

    When the device send information to <account> oauth checkin API
    Then the API should return "registered" message and email account

    Examples:
    | account  |
    | facebook |
    | google   |

  Scenario: [REST_01_06_03]
    Check the Facebook APP user wants to binding google account

    Given the user having APP account from facebook already
    And the user having access token and uuid from Google

    When the device send information to "google" oauth checkin API
    Then the API should return "002" error code and "not binding yet" message

    When the device send information to "google" oauth register API
    Then the API should return user token message

  Scenario: [REST_01_06_04]
    Check the Google APP user wants to binding facebook account

    Given the user having APP account from google already
    And the user having access token and uuid from Facebook

    When the device send information to "facebook" oauth checkin API
    Then the API should return "002" error code and "not binding yet" message

    When the device send information to "facebook" oauth register API
    Then the API should return user token message

  Scenario: [REST_01_06_05]
    Check the user having Facebook portal oauth account before and binding google account

    Given a user using the same email to register facebook portal oauth account already

    When the device send information to "facebook" oauth checkin API
    Then the API should return "003" error code and "not have password" message

    When the device send information to "facebook" oauth register API
    Then the API should return user token message

    When the device send information to "google" oauth checkin API
    Then the API should return "002" error code and "not binding yet" message

    When the device send information to "google" oauth register API
    Then the API should return user token message

  Scenario: [REST_01_06_06]
    Check the user having Google portal oauth account before and binding facebook account

    Given a user using the same email to register google portal oauth account already

    When the device send information to "google" oauth checkin API
    Then the API should return "003" error code and "not have password" message

    When the device send information to "google" oauth register API
    Then the API should return user token message

    When the device send information to "facebook" oauth checkin API
    Then the API should return "002" error code and "not binding yet" message

    When the device send information to "facebook" oauth register API
    Then the API should return user token message

  Scenario Outline: [REST_01_06_07]
    Check the invalid flow when Facebook APP user using invalid access_token

    Given the user having invalid access token and uuid from Facebook

    When the device send information to "facebook" oauth checkin API
    Then the API should return "Invalid Facebook account" error message

    When the device send information to "facebook" oauth register API
    Then the API should return "Invalid Facebook account" error message

  Scenario: [REST_01_06_08]
    Check the invalid flow when Facebook APP user using not exist certificate_serial to register

    Given the user already checkin from Facebook
    And the user having certificate_serial <abcde>

    When the device send information to "facebook" oauth checkin API
    Then the API should return "Invalid Facebook account" error message

  Scenario: [REST_01_06_09]
    Check the invalid flow when APP registered user wants to register

    Given the user having APP account from <account> already
    When the device send information to <account> oauth register API
    Then the API should return "101" error code and "Invalid signature" message

    Examples:
    | account  |
    | facebook |
    | google   |


  Scenario: [REST_01_06_10]
    Check the invalid flow when Facebook APP registered user wants to binding google account with invalid password

    Given the user having APP account from facebook already
    And the user having access token and uuid from Google

    When the device send information to "google" oauth checkin API
    Then the API should return "002" error code and "not binding yet" message

    And the user having password <invalid_password>

    When the device send information to "google" oauth register API
    Then the API should return "004" error code and "invalid info" message
