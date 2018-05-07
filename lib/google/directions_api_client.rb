# frozen_string_literal: true

module Google
  class DirectionsApiClient < ClientHttp
    HTTP_URL = 'https://maps.googleapis.com/maps/api/directions/json'
    API_KEY = ENV.fetch('GOOGLE_DIRECTIONS_API_KEY')

    class BaseError < StandardError; end

    class << self
      def route_polylines(dst:, src:)
        route(dst: dst, src: src)['routes'].first['legs']
                                           .first['steps']
                                           .map { |v| v.dig('polyline', 'points') }
      end

      def route_distance(dst:, src:)
        route(dst: dst, src: src)['routes'].first['legs'].first.dig('distance', 'value')
      end

      def route(dst:, src:)
        query = {
          departure_time: :now,
          origin: location_to_s(src),
          destination: location_to_s(dst),
          alternatives: false,
          mode: :driving,
          key: API_KEY,
          language: :ru
        }

        connection.get(HTTP_URL, query).body
      end

      private

      def location_to_s(lat:, lon:)
        "#{lat}, #{lon}"
      end
    end
  end
end
