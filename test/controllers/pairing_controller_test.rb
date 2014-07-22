require 'test_helper'

class PairingControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
