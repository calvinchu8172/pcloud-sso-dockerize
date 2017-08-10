@javascript
Feature: [OAUTH_04] logout redirect uri

  Background:
    Given A signed in user
    Given 1 existing client app

  Scenario: [OAUTH_04_01]
    client app has logout redirect uri and user will redirect to logout redirect uri after logout

    Given client app has logout redirect uri
      And user visits logout url
     Then user will be redirect to logout redirect uri

  Scenario: [OAUTH_04_02]
    client app doesn't have logout redirect uri and user will redirect to login page after logout

    Given user visits logout url
     Then user will be redirect to login page

  Scenario: [OAUTH_04_03]
    client app has logout redirect uri and user will redirect to login page after logout without client_id

    Given client app has logout redirect uri
      And user visits logout url without client_id
     Then user will be redirect to login page

  Scenario: [OAUTH_04_04]
    client app has logout redirect uri and user will redirect to login page after logout without log_redirect_uri

    Given client app has logout redirect uri
      And user visits logout url without logout_redirect_uri
     Then user will be redirect to login page

  Scenario: [OAUTH_04_05]
    client app has logout redirect uri and user will redirect to login page after logout without log_redirect_uri

    Given client app has logout redirect uri
      And the user's session is expired
      And user visits logout url
     Then user will be redirect to logout redirect uri



