class AddOwnerAndCreatorToProject < ActiveRecord::Migration
  def change
    add_column :projects, :owner, :integer
    add_column :projects, :creator, :integer
  end
end
