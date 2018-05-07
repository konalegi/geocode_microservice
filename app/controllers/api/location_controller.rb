# frozen_string_literal: true

module Api
  class LocationController < ApplicationController
    rescue_from LocationClient::NotFoundError, with: -> { head :not_found }
    rescue_from(
      Route::InRegion::BaseError,
      LocationClient::AdapterNotFound,
      with: :render_422_error
    )

    def geocode
      result = LocationClient.geocode(symbolized_params.slice(:adapter_name, :address))
      render json: result
    end

    def distance_from_city
      distance = Route::InRegion.distance_from_city(distance_from_city_params)
      render json: { distance: distance}
    end

    private

    def distance_from_city_params
      params.permit(:city_name, dst: [:lat, :lon]).to_h.deep_symbolize_keys
    end

    def render_422_error(ex)
      render json: { errors: [ex.message] }, status: :unprocessable_entity
    end
  end
end
