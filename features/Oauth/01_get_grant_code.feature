@javascript
Feature: [OAUTH_01] get grant code

  Background:
    Given an oauth client user exists
      And 1 existing client app

  Scenario: [OAUTH_01_01]
    User authorizes client app and get grant code

    Given user visits authorization page
      And the user filled the correct login information
     When the user click "SIGN IN" button
     When the user click "Skip" link
     When the user click "Authorize" button
     Then user will be redirect to his app url with grant code.

  Scenario: [OAUTH_01_02]
    User denies aithorization and get deny message

    Given user visits authorization page
      And the user filled the correct login information
     When the user click "SIGN IN" button
     When the user click "Skip" link
     When the user click "Deny" button
     Then user will be redirect to his app url with deny message

  Scenario Outline: [OAUTH_01_03]
    User gets error message with error params

    Given user visits authorization page with wrong "<params>"
      And the user filled the correct login information
     When the user click "SIGN IN" button
     When the user click "Skip" link
     Then user see the "<error_message>" on page
    Examples:
      | params                | error_message             |
      | invalid_client_id     | invalid_client            |
      | invalid_redirect_uri  | invalid_redirect_uri      |
      | invalid_response_type | unsupported_response_type |
     
  Scenario Outline:  [OAUTH_01_04]
    Client app changes theme color

    Given user visits authorization page with <color> theme
     Then the theme color is <color_code>
    Examples:
      | color          | color_code       |
      | blue           | rgb(0, 178, 255) |
      | green          | rgb(100, 190, 0) |
      | yellow         | rgb(255, 200, 3) |
      | orange         | rgb(255, 138, 3) |
      | red            | rgb(255, 41, 56) |