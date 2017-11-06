module V1::Entities
  class CategoryData
    class AsNested < Grape::Entity
      expose :id, documentation: { type: "Integer", desc: "The ID of the benchmark." }
      expose :title, documentation: { type: "String", desc: "The benchmark title." }
      expose :description, documentation: { type: "String", desc: "The Category's description." }
      expose :color_hex, documentation: { type: "String", desc: "The Category's color as a hex value." }
      expose :icon_class, documentation: { type: "String", desc: "The Category's class of icon." }
      expose :links do
        expose :self_link, documentation: { type: "URI", desc: "The link for the full category entity." }, as: :self
      end
    end

    class AsSearch < AsNested
    end

    class AsFull < AsSearch
    end
  end
end
