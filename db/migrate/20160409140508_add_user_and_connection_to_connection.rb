class AddUserAndConnectionToConnection < ActiveRecord::Migration
  def change
    add_column :connections, :user_id, :integer
    add_column :connections, :connection_id, :integer
  end
end
