class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.references :user, null: false

      t.timestamps null: false
    end
  end
end
