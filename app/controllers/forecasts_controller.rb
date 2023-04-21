class ForecastsController < ApplicationController
  def show
    if params[:q].present?
      @forecast = Forecast.new(address_input: params[:q])
      @forecast.fetch
      if @forecast.error
        flash[:alert] = @forecast.error
        @forecast = nil
      end
    end
  end
end
