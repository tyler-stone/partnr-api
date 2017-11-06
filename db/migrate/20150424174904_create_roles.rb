class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.belongs_to :project, index: true
      t.integer :user
      t.string :title, null: false

      t.timestamps
    end
  end
end
