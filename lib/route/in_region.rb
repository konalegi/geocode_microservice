# frozen_string_literal: true

module Route
  module InRegion
    class BaseError < StandardError; end
    class NoIntersectionFound < BaseError; end
    class TooManyIntersectionsFound < BaseError; end

    class << self
      SQL_TEMPLATE = <<-SQL
       SELECT ST_AsGeoJSON(intersection_point(%<multiline>s, \'%<city_name>s\')) as result;
      SQL

      def distance_from_city(city_name:, dst:)
        dst = eval_dst(dst)
        src = lat_lon_for_city(name: city_name)
        lon, lat = intersection_point(city_name: city_name, src: src, dst: dst)
        Google::DirectionsApiClient.route_distance(src: { lat: lat, lon: lon }, dst: dst)
      end

      private

      def eval_dst(dst)
        return dst unless dst.is_a?(String)
        Google::MapsApiClient.geocode_latlon(address: dst)
      end

      def intersection_point(city_name:, src:, dst:)
        multiline = pg_multinline_from(src: src, dst: dst)
        result = execute(multiline: multiline, city_name: city_name)
        points = result['type'] == 'Point' ? result['coordinates'] : []

        if points.count.zero?
          raise(NoIntersectionFound, "No Intersection found for #{src} to #{dst}")
        elsif points.count > 2
          raise(TooManyIntersectionsFound, "Too many points found for #{src} to #{dst}")
        end

        points
      end

      def execute(multiline:, city_name:)
        sql = format(SQL_TEMPLATE, multiline: multiline, city_name: city_name)
        JSON.parse connection.execute(sql).to_a.first['result']
      end

      def lat_lon_for_city(name:)
        city = City.find_by(name: name)
        raise(ArgumentError, "City with name #{name} is not found") if city.nil?
        { lat: city.lat, lon: city.lon }
      end

      def pg_multinline_from(src:, dst:)
        polylines = Google::DirectionsApiClient.route_polylines(dst: dst, src: src)
        pg_multiline_from_google_polylines(polylines: polylines)
      end

      def pg_multiline_from_google_polylines(polylines:)
        colltection = polylines.map do |polyline|
          "ST_AsEWKT(ST_LineFromEncodedPolyline(\'#{polyline}\'))"
        end.join(',')

        "ST_Collect(ARRAY[#{colltection}])"
      end

      def connection
        ActiveRecord::Base.connection
      end
    end
  end
end
