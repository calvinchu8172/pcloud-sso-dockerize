Feature: Get response from REST
  Scenario: Get good response message from bot
    Given the device with get::
      | mac_address      | 099789665701                                             |
      | serial_number    | A123456                                                  |
      | model_name       | m2131234                                                 |
      | firmware_version | 1.0                                                      |
      | algo             | 1                                                        |
      | signature        | 677303d9df9f26cd696c1c986bd30ca112d98122876516fe1177bd0b |
    When the device request POST http://127.0.0.1:3000/d/1/register
    Then I will get HTTP: 200 and xmpp_acount JSON

  Scenario: Get bad response message from bot
    Given the device with get::
      | mac_address      |  |
      | serial_number    |  |
      | model_name       |  |
      | firmware_version |  |
      | algo             |  |
      | signature        |  |
    When the device request POST http://127.0.0.1:3000/d/1/register
    Then I will get HTTP: 400 and xmpp_acount JSON
