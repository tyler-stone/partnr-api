class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :content, null: false
      t.belongs_to :project, index: true, null: false
      t.belongs_to :user, index: true, null: false

      t.timestamps null: false
    end
  end
end
