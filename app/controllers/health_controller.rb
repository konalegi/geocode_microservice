# frozen_string_literal: true

class HealthController < ActionController::API
  def check
    if params[:health_check_security_token] != ENV.fetch('HEALTH_CHECK_SECURITY_TOKEN')
      head :forbidden
      return
    end

    head :ok
  end
end
