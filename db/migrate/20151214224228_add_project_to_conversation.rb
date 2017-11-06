class AddProjectToConversation < ActiveRecord::Migration
  def change
    add_reference :conversations, :project, foreign_key: true, null: true
  end
end
