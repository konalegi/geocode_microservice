# frozen_string_literal: true

module Mocks
  module Yandex
    module MapsApi
      GEOCODE_RESPONSE_FILE_PATH = "#{File.dirname(__FILE__)}/geocode_response.json.erb"

      def mock_yandex_api_maps_geocode_request(
        address:,
        city:,
        lattitude: rand(0..100),
        longitude: rand(0..100),
        found: true
      )

        params = {
          lattitude: lattitude,
          longitude: longitude,
          locality: city,
          found_count: found ? 1 : 0
        }

        stub_request(:get, ::Yandex::MapsApiClient::HTTP_URL)
          .with(
            query: {
              'geocode' => address,
              'format' => 'json'
            }
          )
          .to_return(
            status: 200,
            body: ErbHelpers.new(template_path: GEOCODE_RESPONSE_FILE_PATH, params: params).render,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      def mock_yandex_api_maps_city_district_request(names:, lattitude:, longitude:)
        feature_members = names.map { |name| { GeoObject: { name: name } } }

        response = {
          response:
              { GeoObjectCollection:
                {
                  metaDataProperty: { GeocoderResponseMetaData: { found: names.count } },
                  featureMember: feature_members
                } }
        }

        stub_request(:get, ::Yandex::MapsApiClient::HTTP_URL)
          .with(
            query: {
              'sco' => 'latlong',
              'format' => 'json',
              'geocode' => [lattitude, longitude].join(','),
              'kind' => 'district'
            }
          ).to_return(
            status: 200,
            body: response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end
    end
  end
end
