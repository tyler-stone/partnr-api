module V1::Entities
  class ConversationData
    class AsNested < Grape::Entity
      expose :id, documentation: { type: "Integer", desc: "The ID of the conversation." }
      expose :updated_at, documentation: { type: "DateTime", desc: "The last time the conversation was updated." }, as: :last_updated
      expose :users, documentation: { type: "UserData (AsNested)", dest: "The users in the conversation", is_array: true }, using: UserData::AsNested
      expose :is_read do |instance, options|
        options[:is_read]
      end
    end

    class AsShallow < AsNested
    end

    class AsDeep < AsShallow
      expose :messages, documentation: { type: "MessageData (AsNested)", desc: "The messages in the conversation.", is_array: true }, using: MessageData::AsNested
    end

    class AsSearch < AsNested
      expose :is_read do |instance, options|
        options[:user_convs].find_by(conversation_id: instance.id).is_read || false
      end
    end

    class AsFull < AsDeep
    end
  end
end
