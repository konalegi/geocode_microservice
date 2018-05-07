# frozen_string_literal: true

module Mocks
  module Google
    module PlacesApi
      def mock_google_api_places_request(name:, status: 'OK')
        stub_request(:get, ::Google::PlacesApiClient::HTTP_URL)
          .with(
            query: hash_including('rankby' => 'distance',
                                  'type' => 'subway_station',
                                  'language' => 'ru')
          )
          .to_return(
            status: 200,
            body: { results: [{ name: name }], status: status }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end
    end
  end
end
