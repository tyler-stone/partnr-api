class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :title
      t.text :description
      t.string :color_hex
      t.string :icon_class

      t.timestamps null: false
    end
  end
end
