# frozen_string_literal: true

class LocationClient
  class BaseError < StandardError; end
  class NotFoundError < BaseError; end
  class AdapterNotFound < BaseError; end

  ADAPATER_ERRORS = [Faraday::Error, Yandex::BaseError, Google::BaseError, DaData::BaseError].freeze
  CACHE_KEY = 'geocode_'

  class << self
    def geocode(address:, adapter_name: nil)
      key = [CACHE_KEY, Digest::MD5.hexdigest(address)].join

      Rails.cache.fetch(key, expires_in: expire_time) do
        adapters = if adapter_name.present?
                     Array.wrap(resolve_adapter(name: adapter_name))
                   else
                     randomized_adapters
                   end

        geocode_with_adapters(address: address, adapters: adapters)
      end
    end

    def geocode_latlon(address:)
      result = geocode(address: address)

      {
        lat: result[:lattitude],
        lon: result[:longitude]
      }
    end

    private

    def resolve_adapter(name:)
      case name
      when 'google'
        Google::MapsApiClient
      when 'dadata'
        DaData::MapsApiClient
      when 'yandex'
        Yandex::MapsApiClient
      else
        raise(AdapterNotFound, "Adapter name with #{name} not found")
      end
    end

    def geocode_with_adapters(address:, adapters:)
      adapters.map do |adapter|
        begin
          return adapter.geocode(address: address)
        rescue *ADAPATER_ERRORS => ex
          Rails.logger.warn("Error for address: #{address}. #{ex.message}")
          next
        end
      end

      raise(NotFoundError)
    end

    def expire_time
      ENV.fetch('GEOCODE_EXPIRE_TIME_IN_HOURS').to_i.hours
    end

    def randomized_adapters
      ([google_adapter, dadata_adapter].shuffle + [yandex_adapter]).reject(&:nil?)
    end

    def yandex_adapter
      Yandex::MapsApiClient if ENV.fetch('YANDEX_ENABLED') == 'true'
    end

    def google_adapter
      Google::MapsApiClient if ENV.fetch('GOOGLE_ENABLED') == 'true'
    end

    def dadata_adapter
      DaData::MapsApiClient if ENV.fetch('DADATA_ENABLED') == 'true'
    end
  end
end
