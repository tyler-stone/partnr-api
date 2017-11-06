class CreateUserConversations < ActiveRecord::Migration
  def change
    create_table :user_conversations do |t|
      t.references :user, index: true, foreign_key: true
      t.references :conversation, index: true, foreign_key: true
      t.boolean :is_read

      t.timestamps null: false
    end

    add_index :user_conversations, [:conversation_id, :user_id]
    drop_table :conversations_users
  end
end
