class AddStatusToConnection < ActiveRecord::Migration
  def change
    add_column :connections, :status, :integer, default: 0, index: true
  end
end
