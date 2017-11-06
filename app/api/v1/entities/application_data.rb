module V1::Entities
  class ApplicationData
    class AsNested < Grape::Entity
      expose :status, documentation: { type: "String", desc: "The application status." }
      expose :id, documentation: { type: "Integer", desc: "The application id." }
      expose :links do
        expose :self_link, documentation: { type: "URI", desc: "The link for the full application entity." }, as: :self
      end
    end

    class AsSearch < AsNested
      expose :role, documentation: { type: "RoleData (nested)", desc: "The role for the application." }, using: RoleData::AsNested
      expose :user, documentation: { type: "UserData (nested)", desc: "The applicant for the role." }, using: UserData::AsNested
    end

    class AsNotification < Grape::Entity
      expose :role, documentation: { type: "RoleData (nested)", desc: "The role for the application." }, using: RoleData::AsNested
      expose :project, documentation: { type: "ProjectData (nested)", desc: "The project on which the application was made." }, using: ProjectData::AsNested
      expose :itself, as: :application do
        expose :id
        expose :links do
          expose :self_link, documentation: { type: "URI", desc: "The link for the full application entity." }, as: :self
        end
      end
    end

    class AsFull < AsSearch
      expose :project, documentation: { type: "ProjectData (nested)", desc: "The project on which the application was made." }, using: ProjectData::AsNested
    end
  end
end
