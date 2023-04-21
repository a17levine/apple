require "test_helper"
require "minitest/mock"

class ForecastTest < ActiveSupport::TestCase
  test "#initialize saves the address input" do
    forecast = Forecast.new(address_input: 'One Infinite Loop, Cupertino, CA 95014')
    assert_equal 'One Infinite Loop, Cupertino, CA 95014', forecast.address_input
  end

  test "#geocode returns lat and long for address" do
    forecast = Forecast.new(address_input: "One Infinite Loop, Cupertino, CA 95014")
    stub_geocode do
      assert_equal forecast.send(:geocode), {
        longitude: -122.0307806,
        latitude: 37.3320084,
      }
      assert_equal "Infinite Loop, Cupertino, CA 95014, USA", forecast.instance_variable_get(:@address_output)
    end
  end

  test "#fetch_current_conditions gets the current conditions" do
    forecast = Forecast.new(address_input: 'One Infinite Loop, Cupertino, CA 95014')
    stub_current_conditions
    response = forecast.send(:fetch_current_conditions, **{
      longitude: -122.0307806,
      latitude: 37.3320084,
    })
    assert_equal 69.39, response["main"]["temp"]
  end

  test "#fetch_forecast gets the forecast" do
    forecast = Forecast.new(address_input: 'One Infinite Loop, Cupertino, CA 95014')
    stub_forecast
    response = forecast.send(:fetch_forecast, **{
      longitude: -122.0307806,
      latitude: 37.3320084,
    })
    assert_equal 5, response["list"].count
    assert_equal 1682024400, response["list"].first["dt"]
  end

  test "#fetch gets both current conditions and forecast" do
    forecast = Forecast.new(address_input: 'One Infinite Loop, Cupertino, CA 95014')
    stub_current_conditions
    stub_forecast
    stub_geocode do
      forecast.fetch
      assert_equal 69.39, forecast.current_conditions["main"]["temp"]
      assert_equal 84.34, forecast.forecast["list"].first["main"]["temp"]
    end
  end

  test "#cached caches weather values if the geolocation has a zip code" do
    Rails.cache.clear
    # Cache miss
    forecast = Forecast.new(address_input: 'One Infinite Loop, Cupertino, CA 95014')
    stub_current_conditions
    stub_forecast
    stub_geocode do
      forecast.fetch
    end
    assert_equal 69.39, Rails.cache.read('current conditions/95014')["main"]["temp"]
    assert_equal 84.34, Rails.cache.read('forecast/95014')["list"].first["main"]["temp"]
    refute forecast.cached_result
    
    # Cache hit on second run
    stub_current_conditions
    stub_forecast
    stub_geocode do
      forecast.fetch
    end
    assert forecast.cached_result
  end

  test "avoids cache if theres no zip code" do
    Rails.cache.clear
    forecast = Forecast.new(address_input: 'One Infinite Loop, Cupertino, CA 95014')
    stub_current_conditions
    stub_forecast
    stub_geocode(include_zip: false) do
      forecast.fetch
    end
    refute forecast.cached_result
    assert Rails.cache.instance_variable_get(:@data).empty?
    
    # Second identical call is also a cache miss 
    stub_current_conditions
    stub_forecast
    stub_geocode(include_zip: false) do
      forecast.fetch
    end
    refute forecast.cached_result
    assert Rails.cache.instance_variable_get(:@data).empty?
  end

  def stub_current_conditions
    stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?APPID=#{Rails.application.credentials.open_weather_map.app_id}&lat=37.3320084&lon=-122.0307806&units=imperial").
    to_return(status: 200, body: File.read("test/fixtures/files/current_conditions.json"), headers: {})
  end

  def stub_forecast
    stub_request(:get, "https://api.openweathermap.org/data/2.5/forecast?APPID=#{Rails.application.credentials.open_weather_map.app_id}&lat=37.3320084&lon=-122.0307806&units=imperial").
      to_return(status: 200, body: File.read("test/fixtures/files/forecast.json"), headers: {})
  end

  def stub_geocode(include_zip: true, &block)
    mock = Minitest::Mock.new
    mock.expect(:address, "Infinite Loop, Cupertino, CA 95014, USA")
    mock.expect(:longitude, -122.0307806)
    mock.expect(:latitude, 37.3320084)
    if include_zip
      mock.expect(:components, { "postal_code" => ["95014"] }) 
    else
      mock.expect(:components, { "postal_code" => [] }) 
    end
    geocoded_output = [mock]
    Google::Maps.stub :geocode, geocoded_output do
      yield
    end
  end
end