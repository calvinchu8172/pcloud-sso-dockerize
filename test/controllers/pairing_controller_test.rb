require 'test_helper'

class PairingControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get find" do
    get :find
    assert_response :success
  end

  test "should get add" do
    get :add
    assert_response :success
  end

  test "should get unpairing" do
    get :unpairing
    assert_response :success
  end

  test "should get success" do
    get :success
    assert_response :success
  end

  test "should get check" do
    get :check
    assert_response :success
  end
end
