class AddRoleToCategory < ActiveRecord::Migration
  def change
    add_column :roles, :category_id, :integer
  end
end
