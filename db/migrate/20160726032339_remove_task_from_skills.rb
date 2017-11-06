class RemoveTaskFromSkills < ActiveRecord::Migration
  def change
    remove_column :skills, :task_id, :integer
  end
end
