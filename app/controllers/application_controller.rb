# frozen_string_literal: true

class ApplicationController < ActionController::API
  def symbolized_params
    @symbolized_params ||= params.permit!.to_h.deep_symbolize_keys
  end
end
