class CreateCategoriesTasksJoinTable < ActiveRecord::Migration
  def change
    create_table :categories_tasks, :id => false do |t|
      t.integer :category_id
      t.integer :task_id
    end
  end
end
