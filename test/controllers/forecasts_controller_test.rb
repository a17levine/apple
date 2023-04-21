require "test_helper"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get root_url
    assert_response :success
  end
end
