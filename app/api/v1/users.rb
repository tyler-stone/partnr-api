require_relative './validators/valid_pagination'
require_relative './validators/length'

module V1
  class Users < Grape::API
    helpers do
      def get_user(id)
        get_record(User, id)
      end
    end


    desc "Retrieve all the users.", entity: Entities::UserData::AsSearch
    params do
      optional :per_page, type: Integer, default: 25, valid_per_page: [1, 100], allow_blank: false, desc: "The number of users per page."
      optional :page, type: Integer, default: 1, allow_blank: false, desc: "The page of the users to get."
    end
    get do
      present User
        .page(params[:page])
        .per(params[:per_page]), with: Entities::UserData::AsSearch, current_user: current_user
    end

    desc "Retrieve info about the current user.", entity: Entities::UserData::AsPrivate
    get :me do
      if authenticated
        present current_user, with: Entities::UserData::AsPrivate
      else
        {}
      end
    end


    desc "Post an avatar photo.", entity: Entities::UserData::AsPrivate
    params do
      requires :image, :type => Rack::Multipart::UploadedFile, :desc => "Image file."
    end
    post :avatar do
      authenticated_user
      current_user.avatar = ActionDispatch::Http::UploadedFile.new(params[:image])
      current_user.save
    end


    desc "Retrieve info for a single user.", entity: Entities::UserData::AsPublic
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The users's ID."
    end
    get ":id" do
      user = get_user(params[:id])
      if authenticated && current_user.id == params[:id]
        present user, with: Entities::UserData::AsPrivate
      else
        present user, with: Entities::UserData::AsPublic, current_user: current_user
      end
    end

    desc "Retrieve the follows for a single user", entity: Entities::FollowData::AsSearch
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The users's ID."
      optional :per_page, type: Integer, default: 25, valid_per_page: [1, 100], allow_blank: false, desc: "The number of users per page."
      optional :page, type: Integer, default: 1, allow_blank: false, desc: "The page of the follows to get."
    end
    get ":id/follows" do
      user = get_user(params[:id])
      present Follow.where(user: user)
        .page(params[:page])
        .per(params[:per_page]), with: Entities::FollowData::AsSearch
    end

    desc "Update the first name, last name, or email", entity: Entities::UserData::AsPrivate
    params do
      optional :first_name, type: String, length: 100, allow_blank: false, desc: "The new first name for the user."
      optional :last_name, type: String, length: 100, allow_blank: false, desc: "The new last name for the user."
    end
    put do
      authenticated_user
      current_user.update!({
        first_name: params[:first_name] || current_user.first_name,
        last_name: params[:last_name] || current_user.last_name
      })
      present current_user, with: Entities::UserData::AsPrivate
    end

    namespace :passwords do
      desc "Update the password for a user", entity: Entities::UserData::AsPrivate
      params do
        requires :old_password, type: String, allow_blank: false, desc: "The old password for the user."
        requires :password, type: String, allow_blank: false, desc: "The new password for the user."
        requires :confirm_password, type: String, allow_blank: false, desc: "Confirm the new password for the user."
      end
      put do
        authenticated_user
        error!("Old password is incorrect", 400) unless current_user.valid_password? params[:old_password]
        current_user.password = params[:password]
        current_user.password_confirmation = params[:confirm_password]
        if current_user.save
          present current_user, with: Entities::UserData::AsPrivate
        else
          error!(current_user.errors.messages.to_json, 400)
        end
      end


      desc "Send the reset password email for a user"
      params do
        requires :email, type: String, allow_blank: false, desc: "The user's email to reset the password."
      end
      get :reset do
        u = User.find_by email: params[:email]
        if u.nil?
          error!("There is no user with that email", 404)
        else
          u.send_reset_password_instructions
          { :message => "Reset instructions were successfully sent to #{params[:email]}" }
        end
      end

      desc "Reset the password given the new one."
      params do
        requires :reset_password_token, type: String, allow_blank: false, desc: "The reset token for the user."
        requires :password, type: String, allow_blank: false, desc: "The new password for the user."
        requires :password_confirmation, type: String, allow_blank: false, desc: "The confirmation for the new password."
      end
      put :reset do
        u = User.reset_password_by_token(params)
        if u.errors.to_json != "{}"
          error!(u.errors.to_json, 400)
        end
        present u, with: Entities::UserData::AsPrivate
      end
    end
  end
end
