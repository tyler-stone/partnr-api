class CreateBmarks < ActiveRecord::Migration
  def change
    create_table :bmarks do |t|
      t.string :title, null: false
      t.boolean :complete, null: false, default: false
      t.datetime :due_date
      t.belongs_to :user, index: true
      t.belongs_to :project, null: false, index: true

      t.timestamps null: false
    end
  end
end
