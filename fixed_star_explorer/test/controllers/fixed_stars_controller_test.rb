require "test_helper"

class FixedStarsControllerTest < ActionDispatch::IntegrationTest
  test "should get home" do
    get fixed_stars_home_url
    assert_response :success
  end

  test "should get show" do
    get fixed_stars_show_url
    assert_response :success
  end
end
