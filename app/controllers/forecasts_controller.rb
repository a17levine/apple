class ForecastsController < ApplicationController
  def show
    if params[:q].present?
      @forecast = Forecast.new(address_input: params[:q])
      @forecast.fetch
    end
  end
end
