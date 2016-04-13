Feature: [Service_01] Ddns expire

  Background:
    Given an user who has a device and pairing

  Scenario: [Service_01_01]
    Ddns record which has been not used for 60 days then device user should receive a warning mail after next scan
    Given device has been not used more than 60 days
     When ddns expire scan
     Then user should receive a warning email
      And ddns record should still exist

  Scenario: [Service_01_02]
    Ddns record which has received warning mail and has been not used for 90 days should be deleted after next scan
    Given device has been not used more than 90 days
      And user has received warning email on previous scan
     When ddns expire scan
     # Then ddns record should be deleted
      And user should not receive any warning email

  Scenario: [Service_01_03]
    Ddns record which has a activity in recent should not receive any warning mail and should not be deleted after next scan
    Given device has been not used more than 1 days
     When ddns expire scan
     Then ddns record should still exist
      And user should not receive any warning email

  Scenario: [Service_01_04]
    Device user has received warning email and device is used recently, Ddns record should not be deleted after next scan
    Given device has been not used more than 1 days
      And user has received warning email on previous scan
     When ddns expire scan
     Then ddns record should still exist
      And user should not receive any warning email

  Scenario: [Service_01_05]
    Device user has received warning email on previous scan, and user should not receive warning email again on next scan
    Given device has been not used more than 60 days
      And user has received warning email on previous scan
     When ddns expire scan
     Then user should not receive any warning email
      And ddns record should still exist
