# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each(&method(:require))
Dir[Rails.root.join('spec/mocks/**/*.rb')].each(&method(:require))

require 'webmock'
require 'webmock/rspec'
include WebMock::API

WebMock.enable!
WebMock.disable_net_connect!

require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

Faker::Config.locale = 'ru'

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryGirl::Syntax::Methods
  config.include RequestHelpers

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
