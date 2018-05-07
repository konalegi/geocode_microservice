# frozen_string_literal: true

source 'https://rubygems.org'

gem 'pg'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'

# Use Puma as the app server
gem 'puma', '~> 3.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Env manangment
gem 'dotenv-rails'

group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'timecop'
  gem 'webmock'
end

group :development do
  gem 'rubocop'
end

gem 'faraday'
gem 'faraday_middleware', '~> 0.11.0.1'
gem 'lograge'

gem 'rack-cors'

# Monitoring
gem 'newrelic_rpm'
gem 'rollbar'

gem 'activerecord-postgis-adapter'

# required to enable caching with memcached
gem 'dalli'
