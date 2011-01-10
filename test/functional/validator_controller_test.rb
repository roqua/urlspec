require 'test_helper'

class ValidatorControllerTest < ActionController::TestCase
  test "should get go" do
    get :go
    assert_response :success
  end

end
