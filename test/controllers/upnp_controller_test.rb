require 'test_helper'

class UpnpControllerTest < ActionController::TestCase
  test "should get search" do
    get :search
    assert_response :success
  end

  test "should get setting" do
    get :setting
    assert_response :success
  end

end
