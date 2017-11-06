require_relative './validators/valid_pagination'
require_relative './validators/length'
require_relative './helpers/param_helper'

module V1
  class Follows < Grape::API

    desc "Retrieve some follow.", entity: Entities::FollowData::AsSearch
    params do
      optional :user, type: Integer, allow_blank: false, desc: "The user ID for the follows to retrieve"
      optional :followable_type, type: String, allow_blank: false, desc: "The class name for the followable"
      optional :followable_id, type: Integer, allow_blank: false, desc: "The ID for the followable"
      optional :per_page, type: Integer, default: 25, valid_per_page: [1, 100], allow_blank: false, desc: "The number of users per page."
      optional :page, type: Integer, default: 1, allow_blank: false, desc: "The page of the users to get."
      at_least_one_of :user, :followable_id
      all_or_none_of :followable_id, :followable_type
    end
    get do
      present Follow.where(permitted_params params)
        .page(params[:page])
        .per(params[:per_page]), with: Entities::FollowData::AsSearch
    end


    desc "Create a new follow.", entity: Entities::FollowData::AsFull
    params do
      requires :followable_type, type: String, default: "Project", allow_blank: false, desc: "The class name for the followable"
      requires :followable_id, type: Integer, allow_blank: false, desc: "The ID for the followable"
    end
    post do
      authenticated_user
      begin
        cls = "#{params[:followable_type]}".constantize
      rescue NameError
        error!("You can't follow that thing!", 400)
      end

      instance = get_record(cls, params[:followable_id])
      f = Follow.find_or_create_by(
        followable_id: instance.id,
        followable_type: params[:followable_type],
        user: current_user
      )
      f.save!
      present f, with: Entities::FollowData::AsFull
    end
  end
end
