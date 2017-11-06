class AddTasksToSkills < ActiveRecord::Migration
  def change
    add_reference :skills, :task, foreign_key: true
  end
end
