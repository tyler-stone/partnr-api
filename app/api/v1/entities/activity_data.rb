module V1::Entities
  class ActivityData
    class AsNested < Grape::Entity
    end

    class AsSearch < AsNested
      expose :id, documentation: { type: "Integer", desc: "The activity id." }
      expose :created_at, documentation: { type: "Time", desc: "The date and time the activity was created." }, as: :sent_at
      expose :owner, as: :actor, documentation: { type: "UserData (nested)", desc: "The actor for this activity." }, using: UserData::AsNested
      expose :trackable_type, as: :subject_type, documentation: { type: "String", desc: "The class of the subject." }
      expose :text, as: :message
      expose :subject do |activity, options|
        entity = "V1::Entities::#{activity.trackable_type}Data::AsNotification".constantize
        entity.represent(activity.trackable).as_json
      end
    end

    class AsFull < AsSearch
    end
  end
end
