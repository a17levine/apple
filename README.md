# Weather

Checks current conditions and forecast for a location.

Most of the logic for this application lives in `app/models/forecast.rb` and is utilized by `app/controllers/forecasts_controller.rb`.

## forecast.rb

Weather is retrieved in the following manner inside the forecast.rb object.

1. In `#initialize`, the `address_input` is saved. An example would be "One Infinite Loop, Cupertino, CA"
2. Once initialized, the object accepts a `#fetch` method which initiates the weather fetching workflow.
3. Inside `#fetch`, `#geocode` takes the address and retrieves latitude, longitude, and a formatted address from Google Maps.
4. `#fetch_current_conditions` and `#fetch_forecast` are both run which query the Open Weather Map API for weather information.
5. The weather fetching code runs within a `#cached` block. `#cached` checks to see whether the address has a zip code. If the address has a zip, the system utilizes Rails Caching to cache the return value for 30 minutes. Future requests with the same zip code will hit the cache and not hit the Open Weather API. If the address does not have a zip, the weather data never caches or reads from the cache.
6. Once completed, the consumer of the object, in this case the `forecasts_controller#show` method, has access to:

* `address_output`: Parsed address
* `current_conditions`: Current weather
* `forecast`: Forecast
* `cached_result`: Boolean, true if the result was fetched from cache, otherwise false.

## APIs

**Google Maps API**: Takes any kind of location and translates it into a latitude and longitude. We also get a parsed address to display to the user. Utilizing the `google-maps` [gem](https://github.com/zilverline/google-maps).

**Open Weather Map API**: Retrieves [current conditions](https://openweathermap.org/current) and [forecasts](https://openweathermap.org/api/hourly-forecast) in 3-hour increments when given a latitude and longitude.

## Caching

Caching is done in-memory. If this app will be used for real-world users, a Redis or Memcached caching system would be more appropriate.

To get caching to work in development run `rails dev:cache`.

## Secrets

Secrets are managed using [Rails custom credentials API](https://edgeguides.rubyonrails.org/security.html#custom-credentials)

## Styling

[Bootstrap 5.2.3](https://getbootstrap.com/docs/5.2/getting-started/introduction/) is being used

## Testing

Run the test suite with `bundle exec rails test`

## Getting started

1. Ensure Ruby 3.2.2 and `bundler` is installed
2. Install gems with `bundle install`
3. Run `bin/rails credentials:edit` to add API keys for `google_maps.api_key` and `open_weather_map.app_id`. More info: [Rails custom credentials API](https://edgeguides.rubyonrails.org/security.html#custom-credentials) 
4. Enable development caching `rails dev:cache`
5. Launch server `bundle exec rails s`
