# frozen_string_literal: true

module Route
  module ImportCityBoundaries
    load "#{Rails.root}/lib/city_data/index.rb"

    class << self
      SQL_TEMPLATE = <<-SQL
        INSERT INTO "cities" ("boundaries", "name",  "lon", "lat")
        VALUES (ST_GeomFromText($1),$2,$3,$4);
      SQL

      def call(city_boundaries: nil)
        (city_boundaries || CITY_BOUNDARIES_DATA).each(&method(:insert))
      end

      private

      def insert(name:, file_name:, lat:, lon:)
        connection.exec_params(SQL_TEMPLATE, [File.read(file_name), name, lon, lat])
      rescue StandardError => ex
        log(ex.message)
      end

      #
      # This method required to easilly mock in specs
      #
      def log(message)
        p message
      end

      def connection
        ActiveRecord::Base.connection.raw_connection
      end
    end
  end
end
