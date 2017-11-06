class AddUserToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :user_id, :integer
    remove_column :roles, :user, :integer
  end
end
