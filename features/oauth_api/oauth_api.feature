Feature: Oauth API

  Background:
    Given a user sign in from APP
    And the user having access token and uuid from Facebook
    And the user having password <abc12345>
    And the user using valid authentication token

  Scenario:
    Standard oauth api registration flow

    When the device send information to "facebook" oauth checkin API
    Then the API should return "001" error code and "unregistered" message

    When the device send information to "facebook" oauth register API
    Then the API should return user token message

  Scenario:
    Check the Facebook APP user wants to checkin

    Given the user having APP account from facebook already

    When the device send information to "facebook" oauth checkin API
    Then the API should return "registered" message and email account

  Scenario:
    Check the Facebook APP user wants to binding google account

    Given the user having APP account from facebook already
    And the user having access token and uuid from Google

    When the device send information to "google" oauth checkin API
    Then the API should return "002" error code and "not binding yet" message

    When the device send information to "google" oauth register API
    Then the API should return user token message

  Scenario:
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

  Scenario:
    Check the invalid flow when Facebook APP user using invalid access_token

    Given the user having invalid access token and uuid from Facebook

    When the device send information to "facebook" oauth checkin API
    Then the API should return "Invalid Facebook account" error message

    When the device send information to "facebook" oauth register API
    Then the API should return "Invalid Facebook account" error message

  Scenario:
    Check the invalid flow when Facebook APP user using not exist certificate_serial to register

    Given the user already checkin from Facebook
    And the user having certificate_serial <abcde>

    When the device send information to "facebook" oauth checkin API
    Then the API should return "Invalid Facebook account" error message

  Scenario:
    Check the invalid flow when Facebook APP registered user wants to register

    Given the user having APP account from facebook already
    When the device send information to "facebook" oauth register API
    Then the API should return "101" error code and "Invalid signature" message

  Scenario:
    Check the invalid flow when Facebook APP registered user wants to binding google account with invalid password

    Given the user having APP account from facebook already
    And the user having access token and uuid from Google

    When the device send information to "google" oauth checkin API
    Then the API should return "002" error code and "not binding yet" message

    And the user having password <invalid_password>

    When the device send information to "google" oauth register API
    Then the API should return "004" error code and "invalid info" message
