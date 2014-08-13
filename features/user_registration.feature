Feature: [PCP_001_01] Sign Up

  Scenario Outline: [PCP_001_01_01]
    Show error messages when email invalid

    Given a user visits sign up page
    And the visitor agreed the terms of use
    And the visitor filled the captcha correctly
    And the visitor filled the invalid "Email" <Email>
    And the visitor filled the user information:
      | Password                | 12345678    |
      | Confirm Password        | 12345678    |

    When the visitor click "Sign Up" button

    Then the visitor should see an error message for "Email"
      
    Examples:
      | Email    |
      |          |
      | abc      |
      | abc@     |
      | abc.com  |

  Scenario Outline: [PCP_001_01_02]
    Show error messages when password invalid

    Given a user visits sign up page
    And the visitor agreed the terms of use
    And the visitor filled the captcha correctly
    And the visitor filled the invalid "Password" <Password>
    And the visitor filled the invalid "Confirm Password" <Password>
    And the visitor filled the user information:
      | Email | abc@email.com  |

    When the visitor click "Sign Up" button

    Then the visitor should see an error message for "Password"
      
    Examples:
      | Password            |
      |                     |
      | pass                |
      | password1234567890  |

  Scenario: [PCP_001_01_03]
    Show error messages when password and confirm password was different

    Given a user visits sign up page
    And the visitor agreed the terms of use
    And the visitor filled the captcha correctly
    And the visitor filled the user information:
      | Email             | abc@email.com   |
      | Password          | 12345678        |
      | Confirm Password  | password        |

    When the visitor click "Sign Up" button

    Then the visitor should see an error message for "Password Confirmation"

  Scenario: [PCP_001_01_04]
    Show error messages when captcha error

    Given a user visits sign up page
    And the visitor agreed the terms of use
    And the visitor filled the captcha incorrectly
    And the visitor filled the user information:
      | Email             | abc@email.com   |
      | Password          | 12345678        |
      | Confirm Password  | 12345678        |

    When the visitor click "Sign Up" button

    Then the visitor should see an error message for Captcha code  

  Scenario: [PCP_001_01_05]
    Show error messages when not agree the terms of use

    Given a user visits sign up page
    And the visitor filled the captcha correctly
    And the visitor filled the user information:
      | Email             | abc@email.com   |
      | Password          | 12345678        |
      | Confirm Password  | 12345678        |

    When the visitor click "Sign Up" button
    
    Then the visitor should see an error message for Terms of Use

  Scenario: [PCP_001_01_06]
    Send email of confirmation and redirect to success page when registration successfully

    Given a user visits sign up page
    And the visitor agreed the terms of use
    And the visitor filled all the required fields:
      | Email             | abc@email.com   |
      | Password          | 12345678        |
      | Confirm Password  | 12345678        |

    When the visitor click "Sign Up" button

    Then the page will redirect to success page
    And one new user created by abc@email.com
    And the new user should receive an email confirmation

  Scenario: [PCP_001_01_07]
    In registration successfully page, should have resend confirm email link and confirm button

    Given a user visits sign up page

    When the visitor success sign up an account:
      | Email             | abc@email.com   |
      | Password          | 12345678        |
      | Confirm Password  | 12345678        |

    Then the page will redirect to success page
    And the new user should see "Resend Confirmation" and "Confirm" button