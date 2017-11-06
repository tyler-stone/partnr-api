module V1::Entities
  class MessageData
    class AsNested < Grape::Entity
      expose :body, documentation: { type: "String", desc: "The message body." }
      expose :id, documentation: { type: "Integer", desc: "The message ID." }
      expose :created_at, documentation: { type: "Time", desc: "The date and time the message was created." }, as: :sent_at
      expose :user, documentation: { type: "UserData (nested)", desc: "The user that sent the message." }, using: UserData::AsNested
    end

    class AsShallow < AsNested
    end
  end
end
