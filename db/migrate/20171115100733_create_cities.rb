# frozen_string_literal: true

class CreateCities < ActiveRecord::Migration[5.1]
  def change
    create_table :cities do |t|
      t.geometry :boundaries, geographic: true, null: false
      t.string :name, null: false
      t.float :lat, null: false
      t.float :lon, null: false
    end

    add_index :cities, :name, unique: true
  end
end
