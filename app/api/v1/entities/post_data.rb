module V1::Entities
  class PostData
    class AsNested < Grape::Entity
      expose :id, documentation: { type: "Integer", desc: "The ID of the role." }
      expose :title, documentation: { type: "String", desc: "The role title." }
      expose :links do
        expose :self_link, documentation: { type: "URI", desc: "The link for the full post entity." }, as: :self
      end
    end

    class AsSearch < AsNested
      expose :content, documentation: { type: "String", desc: "The content of the post." }
    end

    class AsFull < AsSearch
      expose :user, documentation: { type: "UserData (nested)", desc: "The author of the post."}, using: UserData::AsNested
      expose :bmark, documentation: { type: "MilestoneData (nested)", desc: "The project milestone on which this was posted" }, using: BmarkData::AsNested, as: :milestone
    end

    class AsNotification < Grape::Entity
      expose :bmark, documentation: { type: "MilestoneData (nested)", desc: "The project milestone on which this was posted" }, using: BmarkData::AsNested, as: :milestone
      expose :itself, as: :post do
        expose :id
        expose :title
        expose :links do
          expose :self_link, documentation: { type: "URI", desc: "The link for the full post entity." }, as: :self
        end
      end
    end
  end
end
