class ChangeReadToIsReadOnNotifications < ActiveRecord::Migration
  def change
    remove_column :notifications, :read, :boolean
    add_column :notifications, :is_read, :boolean, :default => false
  end
end
