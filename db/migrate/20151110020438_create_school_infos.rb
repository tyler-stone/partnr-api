class CreateSchoolInfos < ActiveRecord::Migration
  def change
    create_table :school_infos do |t|
      t.references :profile, null: false
      t.string :school_name, null: false
      t.integer :grad_year, null: false
      t.string :field

      t.timestamps null: false
    end
  end
end
