ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

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
