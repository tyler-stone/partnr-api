module V1::Entities
  class TaskData
    class AsChild < Grape::Entity
      expose :title, documentation: { type: "String", desc: "The task title." }
      expose :description, documentation: { type: "Integer", desc: "The task description." }
      expose :status, documentation: { type: "String", desc: "The task status." }
      expose :id, documentation: { type: "Integer", desc: "The task id." }
      expose :created_at, documentation: { type: "Integer", desc: "Whent the task was created." }
      expose :user, documentation: { type: "UserData (nested)", desc: "The user working on the task." }, using: UserData::AsNested
      expose :project, documentation: { type: "ProjectData (nested)", desc: "The project this task belongs to." }, using: ProjectData::AsNested
      expose :bmark, documentation: { type: "MilestoneData (nested)", desc: "The milestone this task belongs to." }, using: BmarkData::AsNested, as: :milestone
      expose :categories, documentation: { type: "CategoryData (nested)", desc: "The categories this task has." }, using: CategoryData::AsNested
      expose :skills, documentation: { type: "SkillData (nested)", desc: "The skills this task has." }, using: SkillData::AsSearch
      expose :links do
        expose :self_link, documentation: { type: "URI", desc: "The link for the full task entity." }, as: :self
      end
    end

    class AsSearch < AsChild
    end

    class AsNested < AsChild
      # migrate to using AsChild instead
    end

    class AsNotification < Grape::Entity
      expose :project, documentation: { type: "ProjectData (nested)", desc: "The project this task belongs to." }, using: ProjectData::AsNested
      expose :itself, as: :task do
        expose :title
        expose :id
        expose :skills, documentation: { type: "SkillData (nested)", desc: "The skills this task has." }, using: SkillData::AsSearch
        expose :links do
          expose :self_link, documentation: { type: "URI", desc: "The link for the full task entity." }, as: :self
        end
      end
    end

    class AsFull < AsChild
    end
  end
end
