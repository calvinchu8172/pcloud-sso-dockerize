Feature: XMPP Bot
  
  Scenario: Get response message from bot
    Given the device with get::

      | mac_address      | 099789665701                                             |
      | serial_number    | A123456                                                  |
      | model_name       | m2131234                                                 |
      | firmware_version | 1.0                                                      |
      | algo             | 1                                                        |
      | signature        | 677303d9df9f26cd696c1c986bd30ca112d98122876516fe1177bd0b |

    When the device request POST http://127.0.0.1:3000/d/1/register
    Then I will get HTTP: 200 and xmpp_acount JSON

    Then I use xmpp_acount to ack bot
    Then I will get message from bot
