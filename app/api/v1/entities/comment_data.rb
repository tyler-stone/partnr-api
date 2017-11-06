module V1::Entities
  class CommentData
    class AsNested < Grape::Entity
      expose :content, documentation: { type: "String", desc: "The comment content." }
      expose :id, documentation: { type: "Integer", desc: "The comment ID." }
      expose :created_at, documentation: { type: "Time", desc: "The date and time the comment was created." }
      expose :links do
        expose :self_link, documentation: { type: "URI", desc: "The link for the full comment entity." }, as: :self
      end
      expose :user, documentation: { type: "UserData (nested)", desc: "The user that made the comment." }, using: UserData::AsNested
    end

    class AsSearch < AsNested
    end

    class AsFull < AsSearch
      expose :project, documentation: { type: "ProjectData (nested)", desc: "The project on which the comment was made." }, using: ProjectData::AsNested
    end

    class AsNotification < Grape::Entity
      expose :project, documentation: { type: "ProjectData (nested)", desc: "The project on which the comment was made." }, using: ProjectData::AsNested
      expose :itself, as: :comment do
        expose :id
        expose :links do
          expose :self_link, documentation: { type: "URI", desc: "The link for the full comment entity." }, as: :self
        end
      end
    end
  end
end
