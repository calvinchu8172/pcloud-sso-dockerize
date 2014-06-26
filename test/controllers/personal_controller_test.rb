require 'test_helper'

class PersonalControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get upnp" do
    get :upnp
    assert_response :success
  end

  test "should get ddns" do
    get :ddns
    assert_response :success
  end

  test "should get unpairing" do
    get :unpairing
    assert_response :success
  end

end
