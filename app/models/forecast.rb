class Forecast
  attr_reader :address_input
  attr_reader :address_output
  attr_reader :current_conditions
  attr_reader :forecast
  attr_reader :cached_result
  
  def initialize(address_input:)
    @address_input = address_input
  end

  def fetch
    geocoded_output = geocode
    @current_conditions = fetch_current_conditions(
      latitude: geocoded_output[:latitude],
      longitude: geocoded_output[:longitude]
    )
    @forecast = fetch_forecast(
      latitude: geocoded_output[:latitude],
      longitude: geocoded_output[:longitude]
    )
  end

  private

  def fetch_current_conditions(latitude:, longitude:)
    cached 'current conditions' do
      response = connection.get('weather', {
        lat: latitude,
        lon: longitude,
      })
      JSON.parse(response.body)
    end
  end

  def fetch_forecast(latitude:, longitude:)
    cached 'forecast' do
      response = connection.get('forecast', {
        lat: latitude,
        lon: longitude,
      })
      JSON.parse(response.body)
    end
  end

  def connection
    @connection ||= Faraday.new(
      url: 'https://api.openweathermap.org/data/2.5',
      params: {
        units: 'imperial',
        APPID: Rails.application.credentials.open_weather_map.app_id,
      },
      headers: {'Content-Type' => 'application/json'}
    )
  end

  def geocode
    geocodes = Google::Maps.geocode(address_input)
    throw 'Invalid address' if geocodes.empty?
    @zip_code = geocodes.first.components["postal_code"]&.first
    
    @address_output = geocodes.first.address
    {
      longitude: geocodes.first.longitude,
      latitude: geocodes.first.latitude,
    }
  end

  # To get this to work in development, run `rails dev:cache`
  def cached(label, &block)
    if @zip_code
      # Only cache if we have a zip code
      @cached_result = true
      Rails.cache.fetch("#{label}/#{@zip_code}", expires_in: 30.minutes) do
        # If we're here, there was a cache miss
        @cached_result = false
        yield
      end
    else
      @cached_result = false
      yield
    end
  end
end