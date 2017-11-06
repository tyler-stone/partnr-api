require_relative './validators/valid_user'
require_relative './validators/valid_pagination'
require_relative './validators/length'

module V1
  class Activities < Grape::API
    desc "Receive the activity for something", entity: Entities::ActivityData::AsSearch
    params do
      optional :owner_id, type: Integer, allow_blank: false, desc: "The user ID."
      optional :trackable_id, type: Integer, allow_blank: false, desc: "The subject ID."
      optional :trackable_type, type: String, allow_blank: false, desc: "The subject class."
      optional :per_page, type: Integer, default: 25, valid_per_page: [1, 100], allow_blank: false, desc: "The number of activities per page."
      optional :page, type: Integer, default: 1, allow_blank: false, desc: "The page number of the activities."
      at_least_one_of :owner_id, :trackable_id
      all_or_none_of :trackable_id, :trackable_type
    end
    get do
      params[:trackable_type].capitalize! if params.has_key? :trackable_type
      present PublicActivity::Activity.where(permitted_params params).order("created_at desc")
        .page(params[:page])
        .per(params[:per_page]), with: Entities::ActivityData::AsSearch
    end
  end
end
