require_relative './validators/valid_user'
require_relative './validators/valid_pagination'
require_relative './validators/length'

module V1
  class Partners < Grape::API
    desc "Get the partners for a user", entity: Entities::UserData::AsSearch
    params do
      optional :user, type: Integer, allow_blank: false, desc: "The User ID to look up."
      optional :per_page, type: Integer, default: 25, valid_per_page: [1, 100], allow_blank: false, desc: "The number of comments per page."
      optional :page, type: Integer, default: 1, allow_blank: false
    end
    get do
      if !params.has_key? :user
        authenticated_user
        params[:user] = current_user.id
      end

      @user = get_record(User, params[:user])
      present @user.partners, with: Entities::UserData::AsSearch
    end
  end
end
