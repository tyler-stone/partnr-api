require_relative './validators/valid_user'
require_relative './validators/valid_pagination'
require_relative './validators/length'

module V1
  class Conversations < Grape::API
    helpers do
      def find_conv
        authenticated_user
        @conv = Conversation.find_by(id: params[:id])
        error!("Conversation with id #{params[:id]} was not found", 404) if @conv.nil?
        error!("User is not involved in the conversation", 401) unless @conv.users.include? current_user
      end

      def find_is_read(conv_id)
        current_user.user_conversations.find_by(conversation_id: conv_id).is_read || false
      end
    end

    desc "Retrieve all conversations for the logged in user", entity: Entities::ConversationData::AsShallow
    params do
      optional :project, type: Integer, allow_blank: false, desc: "The ID of the project for which to get the conversation."
    end
    get do
      authenticated_user
      if params.has_key? :project
        proj = Project.find_by(id: params[:project])
        error!("The project with id #{params[:project]} was not found", 404) if proj.nil?
        error!("You are not a part of this project", 401) unless proj.belongs_to_project current_user
        return {} if proj.conversation.nil?
        present proj.conversation, with: Entities::ConversationData::AsDeep, is_read: find_is_read(proj.conversation.id)
      else
        present current_user.conversations.order('updated_at desc'), with: Entities::ConversationData::AsSearch, user_convs: current_user.user_conversations
      end
    end


    desc "Retrieve a single conversation for a logged in user", entity: Entities::ConversationData::AsDeep
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The ID of the conversation to retrieve."
    end
    get ":id" do
      find_conv
      present @conv, with: Entities::ConversationData::AsDeep, is_read: find_is_read(@conv.id)
    end


    desc "Sends a message in the conversation or posts a new one if a conversation doesn't exist", entity: Entities::ConversationData::AsDeep
    params do
      requires :users, type: Array[Integer], allow_blank: false, desc: "The list of user IDs to send the message to.", documentation: { example: "42,87,17,6" }
      optional :message, type: String, length: 1000, allow_blank: false, desc: "The message to add to the conversation."
    end
    post do
      authenticated_user
      users = Set.new(User.where(id: params[:users]) + [current_user]).to_a
      if users.length <= 1
        error!("You can't start a conversation between less than 2 users!", 400)
      end
      convs = users.map { |user| user.conversations.to_a }
      c = nil
      convs.flatten.each do |conv|
        if conv.users == users
          c = conv
        end
      end
      if c.nil?
        users = users.to_a
        c = Conversation.new(users: users)
        c.save!
      end
      if params[:message]
        m = Message.new({
          user: current_user,
          body: params[:message],
          conversation: c
        })
        m.save!
        # manually set the updated_at param
        c.updated_at = m.updated_at
        c.save!
      end
      ucon = c.user_conversations.find_by(user_id: current_user.id)
      ucon.is_read = true
      ucon.save!
      present c, with: Entities::ConversationData::AsDeep, is_read: ucon.is_read
    end


    desc "Sends a message to an existing conversation", entity: Entities::MessageData::AsNested
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The ID of the conversation."
      optional :message, type: String, length: 1000, allow_blank: false, desc: "The message to add to the conversation."
      optional :is_read, type: Boolean
      at_least_one_of :message, :is_read
    end
    put ":id" do
      find_conv

      if params.has_key? :is_read
        ucon = @conv.user_conversations.find_by(user_id: current_user.id)
        ucon.is_read = params[:is_read]
        ucon.save!
      end

      if params.has_key? :message
        # add a new message to the conversation
        m = Message.create!({
          user: current_user,
          body: params[:message],
          conversation: @conv
        })
        @conv.user_conversations.each do |uconv|
          if uconv.user_id == current_user.id
            uconv.is_read = true
          else
            uconv.is_read = false
          end
          uconv.save!
        end
        @conv.updated_at = m.updated_at
        @conv.save!
      end
      present m, with: Entities::MessageData::AsNested
    end


    desc "Deletes a message from an existing conversation", entity: Entities::ConversationData::AsFull
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The ID of the conversation."
      requires :msg_id, type: Integer, allow_blank: false, desc: "The ID of the message."
    end
    delete ":id" do
      find_conv
      msg = get_record(Message, params[:msg_id])
      error!("You can only delete messages you sent.", 401) unless msg.user == current_user
      msg.destroy!
      present @conv, with: Entities::ConversationData::AsDeep, is_read: find_is_read(@conv.id)
    end
  end
end
