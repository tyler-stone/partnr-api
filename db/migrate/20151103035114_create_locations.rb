class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.references :profile, null: false
      t.string :geo_string, null: false

      t.timestamps null: false
    end
  end
end
