# frozen_string_literal: true

namespace :city_boundaries do
  task import: :environment do
    Route::ImportCityBoundaries.call
  end

  task flush: :environment do
    City.delete_all
  end
end
