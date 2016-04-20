Feature: [REST_01_0A] Api::User::OauthController

  Scenario: [REST_01_0A_01]
    get_oauth_data should return facebook data with valid uuid and access token
    Given the client update current access token and uuid from facebook
     When oauth_controller call method: get_oauth_data
     Then get_oauth_data should return valid data info

  Scenario: [REST_01_0A_02]
    get_oauth_data should return nil with invalid uuid or access token
    Given the client has invalid access token or uuid
     When oauth_controller call method: get_oauth_data
     Then get_oauth_data should return nil
