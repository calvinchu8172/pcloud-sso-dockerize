@javascript
Feature: [PCP_007_01] Visit Download EDM Users List Page

  Scenario: [PCP_007_01_01]
    If the user dosen't sign in, he cannot visit the edm users list page and will redirect to root page.

    Given a user visits download edm users list page without signing in
     Then user is redirected to sign in page

  Scenario: [PCP_007_01_02]
    If the user signed in but he is not the admin, he will be redirected to root page.

    Given a user signed in
      And user visits download edm users list page without admin authority
     Then user is redirected to root page

  Scenario: [PCP_007_01_03]
    If the user signed in but the session name key is wrong, he will be redirected to root page.

    Given a user signed in
      And the session name key is wrong
      And user visits download edm users list page without admin authority
     Then user is redirected to root page

  Scenario: [PCP_007_01_03]
    If the user signed in without the session auth key "download_edm_users", he will be redirected to root page.

    Given a user signed in
      And the session name key is right
      And the session auth key doesn't have "download_edm_users"
      And user visits download edm users list page without admin authority
     Then user is redirected to root page

  Scenario: [PCP_007_01_03]
    If the user signed in and he is the admin, he can visit the edm users list page.
    The user only used email account to sign in.

    Given a user signed in
      And the session name key is right
      And user visits download edm users list page with admin authority
     Then user visits the edm users list page
      And we make the csv file name as "EDM-Users-List-20160531072030.csv"
      And the user click on "Download"
      And the user sees the download csv file as "EDM-Users-List-20160531072030.csv"
      And the user sees the csv header include:
      """
      ["id", "email", "edm_accept", "language", "country", "sign_on_by"]
      """
      And the csv content should have user information with sign_on_by "email"

  Scenario: [PCP_007_01_04]
    If the user signed in and he is the admin, he can visit the edm users list page.
    The user also used Facebook and Google to sign in.

    Given a user signed in
      And the session name key is right
      And user also binded the account with Facebook and Google
      And user visits download edm users list page with admin authority
     Then user visits the edm users list page
      And we make the csv file name as "EDM-Users-List-20160531072030.csv"
      And the user click on "Download"
      And the user sees the download csv file as "EDM-Users-List-20160531072030.csv"
      And the user sees the csv header include:
      """
      ["id", "email", "edm_accept", "language", "country", "sign_on_by"]
      """
      And the csv content should have user information with sign_on_by "email/facebook/google_oauth2"

  Scenario: [PCP_007_01_05]
    If the user signed in and he is the admin, he can visit the edm users list page.
    The user also used Facebook to sign in.

    Given a user signed in
      And the session name key is right
      And user also binded the account with Facebook
      And user visits download edm users list page with admin authority
     Then user visits the edm users list page
      And we make the csv file name as "EDM-Users-List-20160531072030.csv"
      And the user click on "Download"
      And the user sees the download csv file as "EDM-Users-List-20160531072030.csv"
      And the user sees the csv header include:
      """
      ["id", "email", "edm_accept", "language", "country", "sign_on_by"]
      """
      And the csv content should have user information with sign_on_by "email/facebook"

  Scenario: [PCP_007_01_06]
    If the user signed in and he is the admin, he can visit the edm users list page.
    The user also used Google to sign in.

    Given a user signed in
      And the session name key is right
      And user also binded the account with Google
      And user visits download edm users list page with admin authority
     Then user visits the edm users list page
      And we make the csv file name as "EDM-Users-List-20160531072030.csv"
      And the user click on "Download"
      And the user sees the download csv file as "EDM-Users-List-20160531072030.csv"
      And the user sees the csv header include:
      """
      ["id", "email", "edm_accept", "language", "country", "sign_on_by"]
      """
      And the csv content should have user information with sign_on_by "email/google_oauth2"