class AddBmarkToTask < ActiveRecord::Migration
  def change
    add_reference :tasks, :bmark, index: true, foreign_key: true
  end
end
