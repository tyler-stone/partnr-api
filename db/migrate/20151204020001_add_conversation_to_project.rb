class AddConversationToProject < ActiveRecord::Migration
  def change
    add_reference :projects, :conversation, index: true, foreign_key: true
  end
end
