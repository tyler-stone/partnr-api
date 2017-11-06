module V1::Entities::Profile
  class LocationData
    class AsNested < Grape::Entity
      expose :id, documentation: { type: "Integer", desc: "The ID of the location" }
      expose :geo_string, documentation: { type: "String", desc: "The location string of the location." }
    end
  end
end
