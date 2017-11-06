require_relative './validators/valid_user'
require_relative './validators/valid_pagination'
require_relative './validators/length'

module V1
  class Walls < Grape::API
    desc "Retrieve the wall for the specified user", entity: Entities::ActivityData::AsSearch
    params do
      requires :id, type: Integer, valid_user: true, allow_blank: false, desc: "The user ID for the activity to retrieve."
      optional :per_page, type: Integer, default: 25, valid_per_page: [1, 100], allow_blank: false, desc: "The number of activities per page."
      optional :page, type: Integer, default: 1, allow_blank: false
    end
    get ":id" do
      acts = PublicActivity::Activity.where(:owner => params[:id])
      acts.collect { |a| a.destroy if dead_activity?(a) }
      present acts.order('created_at desc')
        .page(params[:page])
        .per(params[:per_page]), with: Entities::ActivityData::AsSearch
    end
  end
end
