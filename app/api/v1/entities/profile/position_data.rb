module V1::Entities::Profile
  class PositionData
    class AsNested < Grape::Entity
      expose :id, documentation: { type: "Integer", desc: "The ID of the position" }
      expose :title, documentation: { type: "String", desc: "The title of the position." }
      expose :company, documentation: { type: "String", desc: "The employer of the position." }
    end
  end
end
