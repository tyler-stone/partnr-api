require_relative './validators/valid_pagination'

module V1
  class Categories < Grape::API
    desc "Retrieve all categories", entity: Entities::CategoryData::AsSearch
    params do
      optional :title, type: String, desc: "The title of the category to retrieve."
      optional :color_hex, type: String, desc: "The color_hex of the category to retrieve."
      optional :description, type: String, desc: "The description of the category to retrieve."
      optional :icon_class, type: String, desc: "The icon_class of the category to retrieve."
      optional :per_page, type: Integer, default: 25, valid_per_page: [1, 100], allow_blank: false, desc: "The number of categories per page."
      optional :page, type: Integer, default: 1, allow_blank: false, desc: "The page number of the categories."
    end
    get do
      present Category.where(permitted_params params)
        .page(params[:page])
        .per(params[:per_page]), with: Entities::CategoryData::AsSearch
    end

    desc "Retrieve a specific category.", entity: Entities::CategoryData::AsFull
    params do
      requires :id, type: Integer, desc: "The ID of the category to retrieve."
    end
    get ":id" do
      c = get_record(Category, params[:id])
      present c, with: Entities::CategoryData::AsFull
    end
  end
end
