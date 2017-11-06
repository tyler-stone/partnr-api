class Conversation < ActiveRecord::Base
  has_many :users, through: :user_conversations
  has_many :user_conversations, :dependent => :destroy
  has_many :messages, :dependent => :destroy
end
