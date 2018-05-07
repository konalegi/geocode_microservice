# frozen_string_literal: true

module Google
  class MapsApiClient < ClientHttp
    HTTP_URL = 'https://maps.googleapis.com/maps/api/geocode/json'
    API_KEY = ENV.fetch('GOOGLE_API_MAPS_KEY')

    class BaseError < StandardError; end

    class << self
      def geocode(address:)
        response = geocode_basic(address: address)
        location = response['results'].first.fetch('geometry', {}).fetch('location', {})
        city = extract_address_component(response: response, component: 'locality').first

        {
          city: city,
          lattitude: location['lat'],
          longitude: location['lng']
        }
      end

      def city_disctict(lattitude:, longitude:)
        response = geocode_basic(
          latlng: [lattitude, longitude].join(','),
          result_type: 'sublocality'
        )

        extract_address_component(response: response, component: 'sublocality')
      end

      private

      def extract_address_component(response:, component:)
        (response['results'].map do |result_item|
          found = result_item.fetch('address_components', {})
                             .select { |item| item['types'].include?(component) }

          found.any? ? found.first['long_name'] : nil
        end).reject(&:nil?)
      end

      def geocode_basic(params = {})
        query = { key: API_KEY, language: :ru }.merge(params)
        response = connection.get(HTTP_URL, query).body
        handle_response response
      end
    end
  end
end
