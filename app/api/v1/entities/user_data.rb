module V1::Entities
  class UserData
    class AsNested < Grape::Entity
      expose :name, documentation: { type: "String", desc: "The user's full name." }
      expose :first_name, documentation: { type: "String", desc: "The user's first name." }
      expose :last_name, documentation: { type: "String", desc: "The user's last name." }
      expose :id, documentation: { type: "Integer", desc: "The user's id." }
      expose :links do
        expose :self_link, documentation: { type: "URI", desc: "The link for the full user entity." }, as: :self
        expose :avatar_link, documentation: { type: "URI", desc: "The link for the user's avatar." }, as: :avatar
        expose :gravatar_link, documentation: { type: "URI", desc: "The link for the user's gravatar if they have one" }, as: :gravatar
      end
    end

    class AsSearch < AsNested
      expose :projects, using: ProjectData::AsNested, documentation: { type: "ProjectData (shallow)",
                                                                        desc: "The projects this user is associated with.",
                                                                        is_array: true }
      expose :roles, using: RoleData::AsNested, documentation: { type: "RoleData (shallow)",
                                                                  desc: "The roles this user has on projects.",
                                                                  is_array: true }
      expose :profile, using: ProfileData::AsFull, documentation: { type: "ProfileData (nested)",
                                                                    desc: "The profile of the user"}
      expose :skillset, using: SkillscoreData, documentation: { type: "Object",
                                                                desc: "The skillscore of the user."}, as: :skillscore
      expose :connection_status do |instance, options|
        instance.connection_status options[:current_user]
      end
    end

    class AsPublic < AsSearch
      expose :projects, using: ProjectData::AsSearch
      expose :comments, using: CommentData::AsNested, documentation: { type: "CommentData (nested)",
                                                                        desc: "The comments user has made.",
                                                                        is_array: true }
      expose :tasks, using: TaskData::AsSearch, documentation: { type: "TaskData (nested)",
                                                                        desc: "The tasks to which the user is assigned.",
                                                                        is_array: true }
    end

    class AsPrivate < AsPublic
      expose :email, documentation: { type: "String", desc: "The user's email." }
      expose :authentication_token, documentation: { type: "String", desc: "The user's auth token." }
      expose :applications, using: ApplicationData::AsSearch, documentation: { type: "ApplicationData (shallow)",
                                                                               desc: "The comments user has made.",
                                                                               is_array: true }
    end
  end
end
