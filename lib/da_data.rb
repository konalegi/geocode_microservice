# frozen_string_literal: true

module DaData
  class BaseError < StandardError; end
  class NotFoundError < BaseError; end
  class CannotFindGeoPoints < BaseError; end
end
