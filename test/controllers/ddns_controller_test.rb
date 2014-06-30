require 'test_helper'

class DdnsControllerTest < ActionController::TestCase
  test "should get setting" do
    get :setting
    assert_response :success
  end

  test "should get success" do
    get :success
    assert_response :success
  end

end
