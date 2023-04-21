class ForecastsController < ApplicationController
  def show
    if params[:q].present?
      @forecast = Forecast.new(address_input: params[:q])
      begin
        @forecast.fetch
      rescue
        @forecast = nil
        flash[:alert] = "Invalid input, please check the address."
      end
    end
  end
end
