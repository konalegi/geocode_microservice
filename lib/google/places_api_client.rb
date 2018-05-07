# frozen_string_literal: true

module Google
  class PlacesApiClient < ClientHttp
    HTTP_URL = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
    API_KEY = ENV.fetch('GOOGLE_API_PLACES_KEY')

    class << self
      def find_nearest_subway_name(longitude:, lattitude:)
        response = find_nearest_subway(longitude: longitude, lattitude: lattitude)
        response['results'].first['name']
      end

      def find_nearest_subway(longitude:, lattitude:)
        query = {
          location: [lattitude, longitude].join(','),
          rankby: :distance,
          type: :subway_station,
          language: :ru,
          key: API_KEY
        }

        handle_response connection.get(HTTP_URL, query).body
      end
    end
  end
end
