# frozen_string_literal: true

module Google
  class BaseError < StandardError; end
  class NotFoundError < BaseError; end
  class ClientConnectionError < BaseError; end
  class EmptyResponseError < BaseError; end
  class UnknownError < BaseError; end
end
