class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.integer :status, default: 0
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
