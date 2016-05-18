Feature: [PCP_001_02] Reset Password

  Background:
    Given a user forgot the password
      And the user visits Forgot My Password page

  Scenario: [PCP_001_02_01]
    Show error messages when email was blank
     When the user didn't filled email
     Then the user should see an error message from reset password

  Scenario: [PCP_001_02_02]
    Show error messages when email not existed
    Given the user filled in an not existed email with "test@example.com"
     When the user click "Submit" button
     Then the user should see an error message from reset password

  Scenario: [PCP_001_02_03]
    Send email of reset password when email existed
    Given the user filled correct email
     When the user click "Submit" button
     Then the user should receive an reset password email

  Scenario: [PCP_001_02_04]
    Resend email of reset password after email been send
     When the user finish reset password
      And the user click "Resend" link
     Then the user will redirect to reset password page
    Given the user filled correct email
      And the user click "Submit" button
     Then the user should receive an reset password email

  Scenario: [PCP_001_02_05]
    Show error messages when password and confirm password was different
     When the user finish reset password
      And the user click reset password email link
      And the user fill in password New:"password1", Confirm:"password2" and submit
     Then the user should see an doesn't match error message

  Scenario: [PCP_001_02_06]
    Redirect to success page when password changed
     When the user finish reset password
      And the user click reset password email link
      And the user fill in password New:"password1", Confirm:"password1" and submit
     Then the user will redirect to reset password success page

  Scenario: [PCP_001_02_07]
    Redirect to login page when user click cancel button in reset password page
     When the user click "Cancel" link
     Then the page will redirect to login page
