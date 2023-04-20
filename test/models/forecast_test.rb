require "test_helper"
require "minitest/mock"

class ForecastTest < ActiveSupport::TestCase
  test "#initialize saves the address input" do
    forecast = Forecast.new(address_input: 'One Infinite Loop, Cupertino, CA 95014')
    assert_equal 'One Infinite Loop, Cupertino, CA 95014', forecast.address_input
  end

  test "#geocode returns lat and long for address" do
    geocoded_output = [
      stub(
        :address => "Infinite Loop, Cupertino, CA 95014, USA",
        :longitude => -122.0307806,
        :latitude => 37.3320084,
      )
    ]
    Google::Maps.stub :geocode, geocoded_output do
      forecast = Forecast.new(address_input: "One Infinite Loop, Cupertino, CA 95014")
      assert_equal forecast.send(:geocode), {
        longitude: -122.0307806,
        latitude: 37.3320084,
      }
      assert_equal "Infinite Loop, Cupertino, CA 95014, USA", forecast.instance_variable_get(:@address_output)
    end
  end

  test "#fetch gets the current conditions and forecast" do
    forecast = Forecast.new(address_input: 'One Infinite Loop, Cupertino, CA 95014')
    forecast.fetch
  end
end