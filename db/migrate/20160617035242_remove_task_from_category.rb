class RemoveTaskFromCategory < ActiveRecord::Migration
  def change
    remove_column :categories, :task_id, :integer
  end
end
