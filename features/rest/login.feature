Feature: login XMPP from REST API
  
  Scenario: 123
    Given XMPP account::

      | xmpp_account     | d127001-01@xmpp.pcloud.ecoworkinc.com/device  |
      | xmpp_password    | QRtjuomrPD                                    |
      | xmpp_bots        | bot1@xmpp.pcloud.ecoworkinc.com/robot         |

    When the device request POST /d/1/register
    Then I will get http code and JSON