Feature: [PCP_001_01] Sign Up

  Background:
    Given a user visits sign up page

  Scenario Outline: [PCP_001_01_01]
    Show error messages when email invalid
    Given the visitor agreed the terms of use
      And the visitor filled the captcha correctly
      And the visitor filled the invalid "E-mail" <E-mail>
      And the visitor filled the user information:
      | Password                | 12345678    |
      | Confirm Password        | 12345678    |
     When the visitor click "Sign Up" button
     Then the visitor should see an error message for "email"
    Examples:
      | E-mail                |
      |                       |
      | personal              |
      | personal@             |
      | personal.example.com  |

  Scenario: [PCP_001_01_02]
    Show error messages when email existed
    Given the email has been existed
      And the visitor agreed the terms of use
      And the visitor filled the captcha correctly
      And the visitor filled the user information
     When the visitor click "Sign Up" button
     Then the visitor should see an error message for "Email"

  Scenario Outline: [PCP_001_01_03]
    Show error messages when password invalid
    Given the visitor agreed the terms of use
      And the visitor filled the captcha correctly
      And the visitor filled the invalid "Password" <Password>
      And the visitor filled the invalid "Confirm Password" <Password>
      And the visitor filled the user information:
      | E-mail | personal@example.com  |
     When the visitor click "Sign Up" button
     Then the visitor should see an error message for "Password"
    Examples:
      | Password            |
      |                     |
      | pass                |

  Scenario: [PCP_001_01_04]
    Show error messages when password and confirm password was different
    Given the visitor agreed the terms of use
      And the visitor filled the captcha correctly
      And the visitor filled the user information:
      | E-mail            | personal@example.com   |
      | Password          | 12345678               |
      | Confirm Password  | password               |
     When the visitor click "Sign Up" button
     Then the visitor should see an error message for "Password Confirmation"

  Scenario: [PCP_001_01_05]
    Show error messages when captcha error
    Given the visitor agreed the terms of use
    And the visitor filled the captcha incorrectly
    And the visitor filled the user information:
      | E-mail            | personal@example.com   |
      | Password          | 12345678               |
      | Confirm Password  | 12345678               |
    When the visitor click "Sign Up" button
    Then the visitor should see an error message for Captcha code

  Scenario: [PCP_001_01_06]
    Show error messages when not agree the terms of use
    Given the visitor filled the captcha correctly
      And the visitor filled the user information:
      | E-mail            | personal@example.com   |
      | Password          | 12345678               |
      | Confirm Password  | 12345678               |
     When the visitor click "Sign Up" button
     Then the visitor should see an error message for Terms of Use

  Scenario: [PCP_001_01_07]
    Send email of confirmation and redirect to success page when registration successfully
    Given the visitor agreed the terms of use
      And the visitor filled all the required fields:
      | E-mail            | personal@example.com   |
      | Password          | 12345678               |
      | Confirm Password  | 12345678               |
     When the visitor click "Sign Up" button
     Then the page will redirect to success page
      And one new user created by personal@example.com
      And the new user should receive an email confirmation

  Scenario: [PCP_001_01_08]
    If user doesn't confirm email yet, user will enter email confirmation notice page after sign up
    When the visitor success sign up an account:
      | E-mail            | personal@example.com   |
      | Password          | 12345678               |
      | Confirm Password  | 12345678               |
    Then user will visit page containing "Resend Confirmation E-mail"

  Scenario: [PCP_001_01_09]
    Redirect to login page after confirmed
     When the visitor success sign up an account:
      | E-mail            | personal@example.com   |
      | Password          | 12345678               |
      | Confirm Password  | 12345678               |
     Then the page will redirect to success page
      And one new user created by personal@example.com
      And the new user should receive an email confirmation
     When the new user confirmed account within email
     Then the page will redirect to confirmed page
     When user click the confirm button
     Then user will redirect to login page
      And user should not see "Unverified" button

  Scenario: [PCP_001_01_10]
    Redirect to login page when user click cancel button in sign up page
     When the user click "Cancel" link
     Then the page will redirect to login page

  Scenario: [PCP_001_01_11]
    Login successfully after log out
    Given the visitor success sign up and login
      And the user click sign out button
     When the user try to sign in
     Then user will login and redirect to dashboard
