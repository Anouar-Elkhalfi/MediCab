require "test_helper"

class CabinetsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get cabinets_new_url
    assert_response :success
  end

  test "should get create" do
    get cabinets_create_url
    assert_response :success
  end
end
