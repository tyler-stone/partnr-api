require_relative './validators/valid_user'
require_relative './validators/valid_pagination'
require_relative './validators/length'

module V1
  class Feeds < Grape::API
    desc "Retrieve the feed for the logged in user", entity: Entities::ActivityData::AsSearch
    params do
      optional :trackable_type, type: String, values: ["Project", "Connection", "Milestone"], allow_blank: false, desc: "The class of the subject to return activity for"
      optional :per_page, type: Integer, default: 25, valid_per_page: [1, 100], allow_blank: false, desc: "The number of activities per page."
      optional :page, type: Integer, default: 1, allow_blank: false
    end
    get do
      authenticated_user
      if params[:trackable_type] == "Milestone"
        params[:trackable_type] = "Bmark"
      end
      acts = current_user.feed.where(permitted_params params)
      acts.collect { |a| a.destroy if dead_activity?(a) }
      present acts
        .page(params[:page])
        .per(params[:per_page]), with: Entities::ActivityData::AsSearch
    end
  end
end
