# frozen_string_literal: true

module Mocks
  module Google
    module DirectionsApi
      def mock_google_api_routes_request(src:, dst:, **params)
        root = File.dirname(__FILE__)
        path = "#{root}/route_response_mock.json.erb"

        params = {
          status: 'OK',
          distance: rand(100..200)
        }.merge(params)

        if dst == { lat: 55.7716472, lon: 49.2374026 }
          path = "#{root}/route_response_mock1.json.erb"
        end

        body = if params[:status] == 'OK'
                 ErbHelpers.new(template_path: path, params: params).render
               else
                 '{}'
               end

        stub_request(:get, ::Google::DirectionsApiClient::HTTP_URL)
          .with(
            query: {
              'departure_time' => 'now',
              'origin' => "#{src[:lat]}, #{src[:lon]}",
              'destination' => "#{dst[:lat]}, #{dst[:lon]}",
              'alternatives' => false,
              'mode' => 'driving',
              'key' => ENV.fetch('GOOGLE_DIRECTIONS_API_KEY'),
              'language' => 'ru'
            }
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
