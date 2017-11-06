module V1::Entities::Profile
  class InterestData
    class AsNested < Grape::Entity
      expose :id, documentation: { type: "Integer", desc: "The ID of the interest" }
      expose :title, documentation: { type: "String", desc: "The name of the interest." }
    end
  end
end
