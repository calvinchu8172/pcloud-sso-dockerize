Feature: Device Registration
  In order to avoid silly mistakes
  As a math idiot
  I want to be told the sum of two numbers

  Scenario: First Time Device Registration
    Given the device with the following payload::
      | mac_address      | 099789665701                                             |
      | serial_number    | A123456                                                  |
      | model_name       | m2131234                                                 |
      | firmware_version | 1.0                                                      |
      | algo             | 1                                                        |
      | signature        | 677303d9df9f26cd696c1c986bd30ca112d98122876516fe1177bd0b |
    When the device requests POST http://pcloud.dev/d/1/register
    Then response should be "200"
    And xmpp_acount is available
