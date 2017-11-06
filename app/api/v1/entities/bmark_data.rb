module V1::Entities
  class BmarkData
    class AsNested < Grape::Entity
      expose :id, documentation: { type: "Integer", desc: "The ID of the milestone." }
      expose :title, documentation: { type: "String", desc: "The milestone title." }
      expose :complete, documentation: { type: "Boolean", desc: "The milestone's completeness." }
      expose :due_date, documentation: { type: "DateTime", desc: "The due date of the milestone." }
      expose :created_at, documentation: { type: "String", desc: "The milestone's create date." }
      expose :links do
        expose :self_link, documentation: { type: "URI", desc: "The link for the full milestone entity." }, as: :self
      end
    end

    class AsSearch < AsNested
    end

    class AsFull < AsSearch
      expose :project, documentation: { type: "ProjectData (nested)", desc: "The project this milestone belongs to." }, using: ProjectData::AsNested
      expose :user, documentation: { type: "UserData (public)", desc: "The user who created the milestone." }, using: UserData::AsNested, as: :creator
      expose :posts, documentation: { type: "PostData (nested)", desc: "The posts on the milestone." }, using: PostData::AsNested
    end

    class AsNotification < Grape::Entity
      expose :project, documentation: { type: "ProjectData (nested)", desc: "The project this milestone belongs to." }, using: ProjectData::AsNested
      expose :itself, as: :milestone do
        expose :id
        expose :title
        expose :links do
          expose :self_link, documentation: { type: "URI", desc: "The link for the full milestone entity." }, as: :self
        end
      end
    end

  end
end
