class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.references :user, index: true, foreign_key: true
      t.references :followable, index: true, polymorphic: true
      t.timestamps null: false
    end
  end
end
