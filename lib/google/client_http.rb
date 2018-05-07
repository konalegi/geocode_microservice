# frozen_string_literal: true

module Google
  class ClientHttp
    CLIENT_CONNECTION_ERROR = %w[OVER_QUERY_LIMIT REQUEST_DENIED INVALID_REQUEST].freeze

    class << self
      def connection
        @connection = Faraday.new do |c|
          c.options[:open_timeout] = ENV.fetch('GOOGLE_HTTP_OPEN_TIMEOUT').to_i
          c.options[:timeout] = ENV.fetch('GOOGLE_HTTP_TIMEOUT').to_i

          c.request :retry,
                    max: ENV.fetch('GOOGLE_HTTP_API_MAX_RETRY').to_i,
                    interval: ENV.fetch('GOOGLE_HTTP_API_RETRY_INTERVAL').to_i,
                    backoff_factor: ENV.fetch('GOOGLE_HTTP_API_BACKOFF_FACTOR').to_i

          c.response :json
          c.adapter :net_http
        end
      end

      #
      # - OK indicates that no errors occurred; the place was successfully detected and
      #   at least one result was returned.
      # - ZERO_RESULTS indicates that the search was successful but returned no results.
      #   This may occur if the search was passed a latlng in a remote location.
      # - OVER_QUERY_LIMIT indicates that you are over your quota.
      # - REQUEST_DENIED indicates that your request was denied, generally because of lack of an
      #   invalid key parameter.
      # - INVALID_REQUEST generally indicates that a required query parameter (location or radius)
      #   is missing.
      #
      def handle_response(response)
        status = response['status']

        if status == 'OK'
          response
        elsif status == 'ZERO_RESULTS'
          raise(NotFoundError)
        elsif CLIENT_CONNECTION_ERROR.include?(status)
          raise(ClientConnectionError, "Google connection error: #{status}")
        elsif response.blank?
          raise(EmptyResponseError)
        else
          raise(UnknownError)
        end
      end
    end
  end
end
