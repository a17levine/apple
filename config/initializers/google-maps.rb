# Config URL: https://console.cloud.google.com/google/maps-apis/home?project=smooth-hub-336103
Google::Maps.configure do |config|
  config.authentication_mode = Google::Maps::Configuration::API_KEY
  config.api_key = Rails.application.credentials.google_maps.api_key
end