# frozen_string_literal: true

module Mocks
  module DaData
    module MapsApi
      GEOCODE_RESPONSE_FILE_PATH = "#{File.dirname(__FILE__)}/geocode_response.json.erb"

      def mock_da_data_api_maps_geocode_request(
        address:,
        city:,
        lattitude: rand(0..100),
        longitude: rand(0..100),
        found: true
      )

        params = {
          lattitude: lattitude,
          longitude: longitude,
          city: city
        }

        body = if found
                 ErbHelpers.new(template_path: GEOCODE_RESPONSE_FILE_PATH, params: params).render
               else
                 '{}'
               end

        stub_request(:post, ::DaData::MapsApiClient::HTTP_URL)
          .with(
            headers: {
              'Content-Type' => 'application/json',
              'Accept' => 'application/json',
              'Authorization' => "Token #{ENV.fetch('DADATA_AUTH_TOKEN')}"
            },
            body: {
              'query' => address,
              'count' => 5
            }.to_json
          )
          .to_return(
            status: 200,
            body: body,
            headers: { 'Content-Type' => 'application/json' }
          )
      end
    end
  end
end
