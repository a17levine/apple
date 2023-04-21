# Weather

Checks current conditions for the location inputted into the address bar.

## APIs

**Google Maps API**: Takes any kind of location and translates it into a latitude and longitude. We also get a parsed address to display to the user. Utilizing the `google-maps` [gem](https://github.com/zilverline/google-maps).

**Open Weather Map API**: Retrieves [current conditions](https://openweathermap.org/current) and [forecasts](https://openweathermap.org/api/hourly-forecast) in 3-hour increments when given a latitude and longitude.

## Caching

Caching is done in-memory. If this app will be used for real-world users, a Redis or Memcached caching system would be more appropriate.

## Secrets

Secrets are managed using [Rails custom credentials API](https://edgeguides.rubyonrails.org/security.html#custom-credentials)

## Getting started

Ensure Ruby 3.2.2 and `bundler` is installed

Install gems with `bundle install`

Launch server `bundle exec rails s`
