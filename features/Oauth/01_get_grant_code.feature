@javascript
Feature: [OAUTH_01] get grant code

  Background:
    Given an oauth client user exists to get grant code
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

  Scenario: [OAUTH_01_03]
    User gets invalid client message on page with invalid client id 

    Given user visits authorization page with "invalid_client_id"
      And the user filled the correct login information
     When the user click "SIGN IN" button
     When the user click "Skip" link
     Then user sees the "invalid_client" message on page

  Scenario: [OAUTH_01_04]
    User gets invalid redirect uri message on page with invalid redirect uri

    Given user visits authorization page with "invalid_redirect_uri"
      And the user filled the correct login information
     When the user click "SIGN IN" button
     When the user click "Skip" link
     Then user sees the "invalid_redirect_uri" message on page
     
  Scenario: [OAUTH_01_05]
    User gets invalid redirect uri message on page with invalid redirect uri

    Given user visits authorization page with "unsupported_response_type"
      And the user filled the correct login information
     When the user click "SIGN IN" button
     When the user click "Skip" link
     Then user sees the "unsupported_response_type" message on page
     
  Scenario Outline:  [OAUTH_01_06]
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