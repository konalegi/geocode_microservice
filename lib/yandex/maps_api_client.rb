# frozen_string_literal: true

module Yandex
  class MapsApiClient
    HTTP_URL = 'https://geocode-maps.yandex.ru/1.x/'

    class Location
      attr_reader :lattitude, :longitude

      def initialize(lat:, lng:)
        @lattitude = lat.to_f
        @longitude = lng.to_f
      end
    end

    class << self
      def geocode(address:)
        response = connection.get(HTTP_URL, format: :json, geocode: address).body
        geo_object_collection = fetch_geo_object_collection!(response: response)
        feature_member = geo_object_collection['featureMember'].first
        lng, lat = feature_member['GeoObject']['Point']['pos'].split(' ').map(&:to_f)
        city = extract_component(feature_member: feature_member, component: 'locality').first

        {
          city: city,
          lattitude: lat,
          longitude: lng
        }
      end

      def extract_component(feature_member:, component:)
        components = feature_member.fetch('GeoObject')
                                   .fetch('metaDataProperty')
                                   .fetch('GeocoderMetaData')
                                   .fetch('Address')
                                   .fetch('Components')

        components.select { |item| item['kind'] == component }.map { |item| item['name'] }
      end

      def city_disctict(lattitude:, longitude:)
        query = {
          sco: :latlong,
          format: :json,
          geocode: [lattitude, longitude].join(','),
          kind: :district
        }

        response = connection.get(HTTP_URL, query).body
        feature_members = fetch_geo_object_collection!(response: response)['featureMember']
        feature_members.map { |item| item['GeoObject']['name'] }
      end

      def fetch_geo_object_collection!(response:)
        goc = response['response']['GeoObjectCollection']
        found = goc['metaDataProperty']['GeocoderResponseMetaData']['found'].to_i
        raise(NotFoundError) if found.zero?
        goc
      end

      def connection
        @connection = Faraday.new do |c|
          c.options[:open_timeout] = ENV.fetch('YANDEX_HTTP_OPEN_TIMEOUT').to_i
          c.options[:timeout] = ENV.fetch('YANDEX_HTTP_TIMEOUT').to_i
          c.request :retry,
                    max: ENV.fetch('YANDEX_HTTP_API_MAX_RETRY').to_i,
                    interval: ENV.fetch('YANDEX_HTTP_API_RETRY_INTERVAL').to_i,
                    backoff_factor: ENV.fetch('YANDEX_HTTP_API_BACKOFF_FACTOR').to_i

          c.response :json, content_type: 'application/json'
          c.adapter :net_http
        end
      end
    end
  end
end
