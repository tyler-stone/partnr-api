class AddUsersToNotifications < ActiveRecord::Migration
  def change
    remove_column :notifications, :user_id
    add_column :notifications, :actor_id, :integer, null: false
    add_column :notifications, :notify_id, :integer, index: true, null: false
  end
end
