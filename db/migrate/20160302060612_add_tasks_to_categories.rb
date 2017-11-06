class AddTasksToCategories < ActiveRecord::Migration
  def change
    add_reference :categories, :task, foreign_key: true
  end
end
