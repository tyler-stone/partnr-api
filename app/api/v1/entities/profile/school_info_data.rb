module V1::Entities::Profile
  class SchoolInfoData
    class AsNested < Grape::Entity
      expose :id, documentation: { type: "Integer", desc: "The ID of the schooling info" }
      expose :school_name, documentation: { type: "String", desc: "The name of the school." }
      expose :grad_year, documentation: { type: "Integer", desc: "The graduation year from the school." }
      expose :field, documentation: { type: "String", desc: "The name of the field of study." }
    end
  end
end
