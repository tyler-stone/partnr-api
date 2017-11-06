module V1::Entities
  class ConnectionData
    class AsNested < Grape::Entity
      expose :id, documentation: { type: "Integer", desc: "The comment ID." }
      expose :links do
        expose :self_link, documentation: { type: "URI", desc: "The link for the full connection entity." }, as: :self
      end
      expose :user, documentation: { type: "UserData (nested)", desc: "The user that requested the connection." }, using: UserData::AsNested
      expose :connection, documentation: { type: "UserData (nested)", desc: "The user that received the connection request." }, using: UserData::AsNested
    end

    class AsSearch < AsNested
      expose :status, documentation: { type: "String", desc: "The connection status." }
    end

    class AsNotification < AsSearch
    end

    class AsFull < AsSearch
    end
  end
end
