# frozen_string_literal: true

module DaData
  class MapsApiClient
    HTTP_URL = 'https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/address'

    class << self
      def geocode(address:)
        response = make_request(address: address)
        suggestion = response.fetch('suggestions', []).first
        raise(NotFoundError, 'Nothing found') if suggestion.nil?
        data = suggestion.fetch('data')

        lat = parse_float!(data.fetch('geo_lat'))
        lon = parse_float!(data.fetch('geo_lon'))
        city = data.fetch('city')

        { city: city, lattitude: lat, longitude: lon }
      end

      def city_disctict(*)
        raise(NotFoundError)
      end

      private

      def make_request(address:)
        connection.post do |req|
          req.url(HTTP_URL)
          req.headers['Authorization'] = "Token #{ENV.fetch('DADATA_AUTH_TOKEN')}"
          req.headers['Content-Type'] = 'application/json'
          req.headers['Accept'] = 'application/json'
          req.body = { query: address, count: 5 }.to_json
        end.body
      end

      def parse_float!(value)
        Float(value)
      rescue StandardError
        raise(CannotFindGeoPoints)
      end

      def connection
        @connection = Faraday.new do |c|
          c.options[:open_timeout] = ENV.fetch('DA_DATA_HTTP_OPEN_TIMEOUT').to_i
          c.options[:timeout] = ENV.fetch('DA_DATA_HTTP_TIMEOUT').to_i
          # c.request  :json, content_type: 'application/json'
          c.request :retry,
                    max: ENV.fetch('DA_DATA_HTTP_API_MAX_RETRY').to_i,
                    interval: ENV.fetch('DA_DATA_HTTP_API_RETRY_INTERVAL').to_i,
                    backoff_factor: ENV.fetch('DA_DATA_HTTP_API_BACKOFF_FACTOR').to_i

          c.response :json, content_type: 'application/json'
          c.adapter :net_http
        end
      end
    end
  end
end
