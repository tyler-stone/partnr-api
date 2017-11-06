class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user, null: false
      t.references :notifier, polymorphic: true, null: false
      t.integer :action, default: 0, null: false
      t.boolean :read, default: true, null: false

      t.timestamps null: false
    end
  end
end
