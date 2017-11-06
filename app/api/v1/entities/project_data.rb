module V1::Entities
  class ProjectData
    class AsNested < Grape::Entity
      expose :title, documentation: { type: "String", desc: "The project title." }
      expose :description, documentation: { type: "Integer", desc: "The project description." }
      expose :status, documentation: { type: "String", desc: "The project status." }
      expose :type, documentation: { type: "String", desc: "The project type."}
      expose :sponsor, documentation: { type: "String", desc: "The project sponsor." }
      expose :formatted_price, documentation: { type: "String", desc: "The project price." }
      expose :id, documentation: { type: "Integer", desc: "The project id." }
      expose :links do
        expose :self_link, documentation: { type: "URI", desc: "The link for the full project entity." }, as: :self
        expose :cover_photo_link, documentation: { type: "URI", desc: "The link for the project cover photo." }, as: :cover_photo
      end
    end

    class AsSearch < AsNested
      expose :comments, documentation: { type: "CommentData (nested)", desc: "The comments on the project." }, using: CommentData::AsNested
      expose :roles, documentation: { type: "RoleData (nested)", desc: "The roles for the project." }, using: RoleData::AsChild
      expose :users, documentation: { type: "UserData (nested)", desc: "The users working on the project." }, using: UserData::AsNested
    end

    class AsFull < AsSearch
      expose :user, documentation: { type: "UserData (nested)", desc: "The project owner." }, using: UserData::AsNested, as: :owner
      expose :roles, documentation: { type: "RoleData (nested)", desc: "The roles for the project." }, using: RoleData::AsChild
      expose :tasks, documentation: { type: "TaskData (child)", desc: "The tasks for the project." }, using: TaskData::AsChild
      expose :bmarks, documentation: { type: "MilestoneData (nested)", desc: "The milestones for the project." }, using: BmarkData::AsNested, as: :milestones
      expose :creator, documentation: { type: "Integer", desc: "The project creator's id." }
    end

    class FullAsMember < AsFull
      expose :applications, documentation: { type: "ApplicationData (nested)", desc: "The applications for all roles on the project." }, using: ApplicationData::AsNested
    end

    class AsNotification < Grape::Entity
      expose :itself, as: :project do
        expose :title
        expose :id
        expose :status, documentation: { type: "String", desc: "The project status." }
        expose :links do
          expose :self_link, documentation: { type: "URI", desc: "The link for the full project entity." }, as: :self
        end
      end
    end
  end
end
