require_relative './validators/valid_user'
require_relative './validators/valid_pagination'
require_relative './validators/length'

module V1
  class Tasks < Grape::API
    helpers do
      def task_create_permissions
        authenticated_user
        @project ||= get_record(Project, params[:project])
        error!("You're not part of this project", 401) unless @project.has_create_task_permissions current_user
      end

      def task_put_permissions
        authenticated_user
        @task ||= get_record(Task, params[:id])
        @project = @task.project
        error!("You're not part of this project", 401) unless @task.has_put_permissions current_user
      end

      def task_destroy_permissions
        authenticated_user
        @task ||= get_record(Task, params[:id])
        error!("You're not part of this project", 401) unless @task.has_destroy_permissions current_user
      end

      def project_milestone_align?
        @milestone = nil
        if params.has_key? :milestone
          if params[:milestone]
            @milestone = get_record(Bmark, params[:milestone])
            error!("That milestone doesn't belong to this project", 400) unless @project.bmarks.member?(@milestone)
          else
            @milestone = nil
            @task.bmark = nil
          end
        end
      end

      def project_user_align?
        @user = nil
        if params.has_key? :user
          if params[:user]
            @user = get_record(User, params[:user])
            error!("That user doesn't belong to this project", 400) unless @project.belongs_to_project(@user)
          else
            @user = nil
            @task.user = nil
          end
        end
      end
    end

    desc "Retrieve a single task based on its ID"
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The task ID."
    end
    get ":id" do
      task = get_record(Task, params[:id])
      present task, with: Entities::TaskData::AsFull
    end

    desc "Retrieve all tasks for a project", entity: Entities::TaskData::AsSearch
    params do
      requires :project, type: Integer, allow_blank: false, desc: "The Project ID for the tasks to retrieve."
      optional :bmark, type: Integer, allow_blank: false, desc: "The milestone ID for the tasks to retrieve"
      optional :title, type: String, desc: "The title of the project task to retrieve."
      optional :per_page, type: Integer, default: 25, valid_per_page: [1, 100], allow_blank: false, desc: "The number of tasks per page."
      optional :page, type: Integer, default: 1, allow_blank: false, desc: "The page number of the tasks."
    end
    get do
      if params.has_key? :milestone
        params[:bmark] = params[:milestone]
        params.delete :milestone
      end

      present Task.where(permitted_params params)
        .page(params[:page])
        .per(params[:per_page]), with: Entities::TaskData::AsSearch
    end


    desc "Create a new task for a proejct", entity: Entities::TaskData::AsFull
    params do
      requires :project, type: Integer, allow_blank: false, desc: "The Project ID for the tasks to create."
      requires :title, type: String, length: 255, desc: "The title of the project task to retrieve."
      optional :description, type: String, length: 1000, allow_blank: false, desc: "The task's description."
      optional :milestone, type: Integer, allow_blank: false, desc: "The milestone ID to create the task under."
      optional :status, type: String, allow_blank: false, values: ["not_started", "in_progress", "complete"], desc: "The task's status."
      optional :user, type: Integer, allow_blank: false, desc: "The user ID to assign the task to."
      optional :skills, type: Array[Integer], desc: "The list of skill IDs to give to this task."
      optional :categories, type: Array[Integer], length: 3, desc: "The list of category IDs to give to this task."
    end
    post do
      task_create_permissions

      # make sure the milestone is a part of the project
      project_milestone_align?
      # make sure the user is on the project
      project_user_align?

      if params.has_key? :status
        params[:status] = { "not_started" => 0, "in_progress" => 1, "complete" => 2 }[params[:status]]
      end

      if params.has_key? :categories
        cats = get_collection(Category, params[:categories])
      end

      if params.has_key? :skills
        skills = get_collection(Skill, params[:skills])
      end

      t = Task.create!({
        title: params[:title],
        description: params[:description],
        project: @project,
        user: @user || nil,
        bmark: @milestone,
        user_notifier: current_user,
        categories: cats || [],
        skills: skills || [],
        status: params[:status] || 0
      })

      if t.complete?
        t.create_activity key: 'activity.task.completed', owner: current_user
      end

      present t, with: Entities::TaskData::AsFull
    end

    desc "Update a task for a project", entity: Entities::TaskData::AsFull
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The task ID to update."
      optional :title, type: String, length: 255, allow_blank: false, desc: "The title of the task to update."
      optional :description, type: String, length: 1000, desc: "The description of the task to update."
      optional :milestone, type: Integer, allow_blank: true, desc: "The milestone ID of the task."
      optional :status, type: String, allow_blank: false, values: ["not_started", "in_progress", "complete"], desc: "The task's status."
      optional :user, type: Integer, allow_blank: true, desc: "The user ID to assign the task to."
      optional :skills, type: Array[Integer], desc: "The list of skill IDs to give to this task."
      optional :categories, type: Array[Integer], length: 3, desc: "The list of category IDs to give to this task."
    end
    put ":id" do
      task_put_permissions
      params[:project] = @task.project.id
      # make sure the milestone is a part of the project
      project_milestone_align?

      # make sure the user is on the project
      project_user_align?

      if params.has_key? :status
        params[:status] = { "not_started" => 0, "in_progress" => 1, "complete" => 2 }[params[:status]]
      end

      skills = @task.skills
      if params.has_key? :skills
        skills = get_collection(Skill, params[:skills])
      end

      categories = @task.categories
      if params.has_key? :categories
        categories = get_collection(Category, params[:categories])
      end

      @task.update!({
        title: params[:title] || @task.title,
        description: params[:description] || @task.description,
        user: @user || @task.user,
        user_notifier: current_user,
        status: params[:status] || @task.status,
        bmark: @milestone || @task.bmark,
        skills: skills,
        categories: categories
      })

      if @task.complete? && @task.previous_changes.has_key?("status")
        @task.create_activity key: 'activity.task.completed', owner: current_user
      end

      present @task, with: Entities::TaskData::AsFull
    end


    desc "Delete a task on a project"
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The task ID to update."
    end
    delete ":id" do
      task_destroy_permissions
      if @task.destroy
        204
      else
        "Could not delete the task"
      end
    end
  end
end
