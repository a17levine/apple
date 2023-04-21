require "test_helper"
require "minitest/mock"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get root_url
    assert_response :success
  end

  test "should fetch forecast if a query is provided" do
    stub_current_conditions
    stub_forecast
    stub_geocode do
      get root_url, params: { q: "Infinite Loop, Cupertino, CA 95014, USA"}
      assert_select 'h4', 'Current conditions'
    end
  end

  test "should return an error on fetch if a query is invalid" do
    stub_current_conditions
    stub_forecast
    forecast_object = Forecast.new(address_input: 'One Infinite Loop, Cupertino, CA 95014')
    forecast_object.instance_variable_set(:@error, "Invalid input, please check the address.")
    Forecast.stub :new, forecast_object do
      stub_geocode do
        get root_url, params: { q: "Infinite Loop, Cupertino, CA 95014, USA"}
        assert_select 'div', 'Invalid input, please check the address.'
      end
    end
  end
end
