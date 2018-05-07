# frozen_string_literal: true

class ErbHelpers
  attr_reader :template_path, :params

  def initialize(template_path:, params:)
    @template_path = template_path
    @params = params

    params.each do |key, value|
      instance_variable_set(:"@#{key}", value)
    end
  end

  def render
    payload = File.read(template_path)
    ERB.new(payload).result(binding)
  end
end
