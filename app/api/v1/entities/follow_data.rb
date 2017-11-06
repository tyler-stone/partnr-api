module V1::Entities
  class FollowData
    class AsNested < Grape::Entity
      expose :id, documentation: { type: "Integer", desc: "The ID of the conversation." }
      expose :user, documentation: { type: "UserData::AsShallow", desc: "The user that followed the subject." }, using: UserData::AsNested, as: :follower
      expose :created_at, documentation: { type: "Time", desc: "The date and time the follow was created." }
      expose :followable_type, documentation: { type: "String", desc: "The class of the followable." }, as: :following_class
      expose :following do |follow, options|
        entity = "V1::Entities::#{follow.followable_type}Data::AsNested".constantize
        cls = "#{follow.followable_type}".constantize
        instance = cls.find follow.followable_id
        entity.represent(instance).as_json
      end
    end

    class AsSearch < AsNested
    end

    class AsFull < AsNested
    end
  end
end
