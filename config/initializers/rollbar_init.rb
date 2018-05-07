Rollbar.configure do |config|
  config.enabled = ENV['ROLLBAR_ACCESS_TOKEN'].present?
  config.access_token = ENV['ROLLBAR_ACCESS_TOKEN'].presence
  config.environment = ENV['ROLLBAR_ENVIRONMENT'].presence || Rails.env
  config.exception_level_filters['ActionController::RoutingError'] = 'ignore'
end
