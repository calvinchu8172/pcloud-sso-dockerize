Feature: [PCP_001_03] Login

  Background:
    Given a user want to login
    And the user visits login page

  Scenario Outline: [PCP_001_03_01]
    Show valid language when user change language

    Given the user change language <Language>
    Then the user should see Sign In word in correct language
    And the user language information will be changed after user login to system

    Examples:
      | Language       |
      | English        |
      | Deutsch        |
      | Nederlands     |
      | 正體中文        |
      | ไทย            |
      | Türkçe         |

  Scenario: [PCP_001_03_02]
    Show error messages when email or password invalid

    Given the user filled the invalid information

    When the user click "Sign in" button

    Then the user should see the error message


  Scenario: [PCP_001_03_03]
    Redirect to resend email of confirmation page when the user login successfully with an uncionfirmed account registered for over 3 days

    Given the user try to login with an unconfirmed account
    And the user has registered more than 3 days
    And the user filled the correct information

    When the user click "Sign in" button

    Then the page should redirect to resend email of confirmation page


  Scenario: [PCP_001_03_04]
    Redirect to the personal devices page when user login successfully with an uncionfirmed account registered not over 3 days

    Given the user try to login with an unconfirmed account
    # And the user was registered not over 3 days
    And the user filled the correct information

    When the user click "Sign in" button

    Then user will login and redirect to dashboard
    And the user should see the information when login successfully


  Scenario: [PCP_001_03_05]
    Show information when login successfully

    Given the user filled the correct information
    And the account was confirmed

    When the user click "Sign in" button

    Then user will login and redirect to dashboard

  Scenario: [PCP_001_03_06]
    Show "unverified" button when login successfully with an unconfirmed account registered not over 3 days

    Given the user filled the correct information
    # And the account was unconfirmed

    When the user click "Sign in" button

    Then the user should see "unverified" button


  Scenario: [PCP_001_03_07]
    Redirect to resend email of confirmation page when clicking "Unverified" button

    Given the user filled the correct information

    When the user click "Sign in" button

    Then the user should see "unverified" button

    When the user click unverified link
    Then the page should redirect to resend email of confirmation page

  Scenario: [PCP_001_03_08]
    Resend confirmation email

    Given the user filled the correct information

    When the user click "Sign in" button
    And the user click unverified link
    And the user click "Resend confirmation email" button

    Then confirmation email should be delivered
    And the page should redirect to hint confirmation sent page

    When the user click "Confirm" link

    Then the page should redirect to sign in page

  Scenario: [PCP_001_03_09]
    Change confirmation email address and resend

    Given the user filled the correct information

    When the user click "Sign in" button
    And the user click unverified link
    And the user click "Change to another email" link

    And fill changing email "new@example.com"
    And the user click "Submit" button

    Then new confirmation email should be delivered
    And the user email account should be changed to "new@example.com"

  Scenario: [PCP_001_03_10]
    Change confirmation email address but already existed

    Given the user filled the correct information
    And an existing user's email is "andy@example.com"

    When the user click "Sign in" button
    And the user click unverified link
    And the user click "Change to another email" link
    And fill changing email "andy@example.com"
    And the user click "Submit" button

    Then the page should redirect to edit email confirmation page
