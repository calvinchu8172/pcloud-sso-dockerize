Feature: Request User's Device List API Testing


Background:
  Given a user sign in from APP
  And the user get a authentication token already

Scenario: [REST_05_01]
  request user device list with valid authentication token

  Given a user try to request own device list from APP
  When APP request POST to https://api-mycloud.zyxel.com/resources/1/device_list
  Then APP will get HTTP: 201
  And the JSON should include ["xmpp_account","mac_address","host_name","wan_ip","firmware_ver","last_update_time", "is_owner"]

Scenario: [REST_05_02]
  request user device list with expired authentication token

  Given a client didn’t use app after sign up for more than 3600 seconds
  And the client try to request own device list from APP
  When APP request POST to https://api-mycloud.zyxel.com/resources/1/device_list
  Then APP will get HTTP: 400
  And the JSON response at "result" should be "invalid"
  And the JSON response at "message" should be "Invalid cloud id or token"