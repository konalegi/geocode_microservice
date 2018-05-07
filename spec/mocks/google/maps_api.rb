# frozen_string_literal: true

module Mocks
  module Google
    module MapsApi
      GEOCODE_RESPONSE_FILE_PATH = "#{File.dirname(__FILE__)}/geocode_response.json.erb"

      def mock_google_api_maps_geocode_request(
        address:,
        city:,
        lattitude: rand(0..100),
        longitude: rand(0..100),
        status: 'OK'
      )

        params = {
          lattitude: lattitude,
          longitude: longitude,
          locality: city,
          response_status: status
        }

        body = if status.nil?
                 '{}'
               else
                 ErbHelpers.new(template_path: GEOCODE_RESPONSE_FILE_PATH, params: params).render
               end

        stub_request(:get, ::Google::MapsApiClient::HTTP_URL)
          .with(
            query: {
              'address' => address,
              'key' => ::Google::MapsApiClient::API_KEY,
              'language' => 'ru'
            }
          )
          .to_return(
            status: 200,
            headers: { 'Content-Type' => 'application/json' },
            body: body
          )
      end

      def mock_google_api_maps_city_district_request(names:, lattitude:, longitude:, status: 'OK')
        results = names.map do |name|
          {
            address_components: [
              {
                'long_name' => name,
                'short_name' => 'Советский р-н',
                'types' => %w[political sublocality sublocality_level_2]
              },
              {
                'long_name' => 'Казань',
                'short_name' => 'Казань',
                'types' => %w[locality political]
              }
            ]
          }
        end

        response = { results: results, status: status }

        stub_request(:get, ::Google::MapsApiClient::HTTP_URL)
          .with(
            query: {
              'latlng' => [lattitude, longitude].join(','),
              'result_type' => 'sublocality',
              'key' => ::Google::MapsApiClient::API_KEY,
              'language' => 'ru'
            }
          )
          .to_return(
            status: 200,
            body: response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end
    end
  end
end
