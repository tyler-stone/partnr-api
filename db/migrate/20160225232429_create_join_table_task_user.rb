class CreateJoinTableTaskUser < ActiveRecord::Migration
  def change
    drop_table 'tasks_users' if ActiveRecord::Base.connection.table_exists? 'tasks_users'

    create_join_table :tasks, :users do |t|
       t.index [:task_id, :user_id]
       t.index [:user_id, :task_id]
    end
  end
end
