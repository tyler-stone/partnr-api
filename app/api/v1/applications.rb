require_relative './validators/valid_user'
require_relative './validators/valid_pagination'
require_relative './validators/length'

module V1
  class Applications < Grape::API
    helpers do
      def application_view_permissions
        authenticated_user
        if params.has_key? :project
          @project ||= get_record(Project, params[:project])

          if params.has_key? :user
            # you need to be the requested user or be on the project to see the applications
            error!("You can't view the applications on this project", 401) unless (params[:user] == current_user.id ||
                                                                                   @project.belongs_to_project(current_user))
          else
            # you need to be on the project if you want to see its applications
            error!("You can't view the applications on this project", 401) unless @project.belongs_to_project current_user
          end
        else
          error!("You can't view this user's applications", 401) unless params[:user] == current_user.id
        end
      end

      def application_destroy_permissions(id)
        authenticated_user
        @application ||= get_record(Application, params[:id])
        error!("401 Unauthorized", 401) unless @application.has_destroy_permissions current_user
      end

      def application_udpate_permissions(id)
        authenticated_user
        @application ||= get_record(Application, params[:id])
        error!("401 Unauthorized", 401) unless @application.has_update_permissions current_user
      end

      def application_accept_permissions(id)
        authenticated_user
        @application ||= get_record(Application, params[:id])
        error!("401 Unauthorized", 401) unless @application.has_accept_permissions current_user
      end
    end

    desc "Retrieve all applications.", entity: Entities::ApplicationData::AsSearch
    params do
      optional :user, type: Integer, allow_blank: false, desc: "The applicant's ID."
      optional :project, type: Integer, allow_blank: false, desc: "The application's project's ID."
      optional :show_rejected, type: Boolean, allow_blank: false, default: false, desc: "The application's project's ID."
      optional :role, type: Integer, allow_blank: false, desc: "The application's role's ID."
      optional :per_page, type: Integer, default: 25, valid_per_page: [1, 100], allow_blank: false, desc: "The number of roles per page."
      optional :page, type: Integer, default: 1, allow_blank: false, desc: "The page number of the roles."
      at_least_one_of :user, :project
    end
    get do
      application_view_permissions

      if not params[:show_rejected]
        not_params = { :status => 2 }
      else
        not_params = {}
      end
      params.delete :show_rejected
      present Application.where(permitted_params params).where.not(not_params)
        .page(params[:page])
        .per(params[:per_page]), with: Entities::ApplicationData::AsSearch
    end


    desc "Get a single application based on its ID.", entity: Entities::ApplicationData::AsFull
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The application ID."
    end
    get ":id" do
      application = get_record(Application, params[:id])
      params[:project] = application.project.id
      params[:user] = application.user.id
      application_view_permissions
      present application, with: Entities::ApplicationData::AsFull
    end


    desc "Create a new application for a role.", entity: Entities::ApplicationData::AsFull
    params do
      requires :role, type: Integer, allow_blank: false, desc: "The role ID to which the application will belong."
    end
    post do
      authenticated_user
      role = Role.find_by(id: params[:role])
      error!("Role #{params[:role]} does not exist", 400) if role.nil?
      if role.project.belongs_to_project(current_user)
        error!("You cannot apply for a role when you're already working on the project!", 400)
      end
      a = Application.new
      a.user_notifier = current_user
      a.update!({
        role: role,
        user: current_user,
        project: role.project
      })
      present a, with: Entities::ApplicationData::AsFull
    end


    desc "Update a specific application for a role.", entity: Entities::ApplicationData::AsFull
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The appliction's ID."
      requires :status, type: String, allow_blank: false, values: ["pending", "accepted"], desc: "The application's status."
    end
    put ":id" do
      @application = get_record(Application, params[:id])
      @role = @application.role
      @role.user_notifier = current_user
      @application.user_notifier = current_user
      if params[:status] == "accepted"
        application_accept_permissions(params[:id])
        if @role.user.nil?
          @role.user = @application.user
          @application.status = "accepted"
          @role.save!
          @role.create_activity key: 'activity.role.accepted', owner: @application.user
          @application.project.update_conversation
        else
          error!("400 Bad Request: Role already has a user.", 400)
        end
      else
        # change status to 'pending'
        application_udpate_permissions(params[:id])
        if @role.user == @application.user
          @role.user = nil
          @role.save!
        end
        @application.status = "pending"
      end
      @application.save!
      present @application, with: Entities::ApplicationData::AsFull
    end

    desc "Destroy an application."
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The application's ID."
    end
    delete ":id" do
      application_destroy_permissions(params[:id])
      @application.user_notifier = current_user
      @application.status = 2
      @application.save
      status 204
    end

  end
end
