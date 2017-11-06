require_relative './validators/valid_user'
require_relative './validators/valid_pagination'
require_relative './validators/length'

module V1
  class Benchmarks < Grape::API
    helpers do
      def benchmark_put_permissions(id)
        authenticated_user
        @benchmark ||= get_record(Bmark, id)
        error!("401 Unauthorized", 401) unless @benchmark.has_put_permissions current_user
      end

      def benchmark_destroy_permissions(id)
          authenticated_user
          @benchmark ||= get_record(Bmark, id)
          error!("401 Unauthorized", 401) unless @benchmark.has_destroy_permissions current_user
      end
    end


    desc "Retrieve all milestones for a project", entity: Entities::BmarkData::AsSearch
    params do
      requires :project, type: Integer, allow_blank: false, desc: "The Project ID for the milestones to retreive."
      optional :title, type: String, desc: "The title of the project milestone to retrieve."
      optional :per_page, type: Integer, default: 25, valid_per_page: [1, 100], allow_blank: false, desc: "The number of milestones per page."
      optional :page, type: Integer, default: 1, allow_blank: false, desc: "The page number of the milestones."
    end
    get do
      present Bmark.where(permitted_params params)
        .page(params[:page])
        .per(params[:per_page]), with: Entities::BmarkData::AsSearch
    end


    desc "Get a single milestone based on its ID.", entity: Entities::BmarkData::AsFull
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The milestone ID."
    end
    get ":id" do
      benchmark = get_record(Bmark, params[:id])
      present benchmark, with: Entities::BmarkData::AsFull
    end


    desc "Create a new milestone for a project.", entity: Entities::BmarkData::AsFull
    params do
      requires :title, type: String, length: 1000, allow_blank: false, desc: "The title of the milestone for the project."
      requires :project, type: Integer, allow_blank: false, desc: "The project ID to which the milestone will belong."
      optional :due_date, type: DateTime, allow_blank: false, desc: "The milestone's due date."
    end
    post do
      authenticated_user
      proj = get_record(Project, params[:project])
      if proj.has_create_benchmark_permissions current_user
        b = Bmark.new
        b.user_notifier = current_user
        b.update!({
          title: params[:title],
          project: proj,
          due_date: params[:due_date],
          user: current_user
        })
        present b, with: Entities::BmarkData::AsFull
      else
        error!("401 Unauthorized", 401)
      end
    end


    desc "Update a specific milestone for a project.", entity: Entities::BmarkData::AsFull
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The milestone ID."
      optional :title, type: String, length: 1000, allow_blank: false, desc: "The milestone title."
      optional :complete, type: Boolean, allow_blank: false, desc: "The milestone's completeness."
      # this needs to be in iso8601 format:
      # https://en.wikipedia.org/wiki/ISO_8601
      optional :due_date, type: DateTime, allow_blank: false, desc: "The milestone's due date."
      at_least_one_of :title, :complete, :due_date
    end
    put ":id" do
      benchmark_put_permissions(params[:id])
      @benchmark.user_notifier = current_user
      @benchmark.update!({
        title: params[:title] || @benchmark.title,
        complete: params[:complete].nil? ? @benchmark.complete : params[:complete],
        due_date: params[:due_date] || @benchmark.due_date
      })
      if @benchmark.complete && @benchmark.previous_changes.has_key?("complete")
        @benchmark.create_activity key: 'activity.benchmark.completed', owner: current_user
      end
      present @benchmark, with: Entities::BmarkData::AsFull
    end


    desc "Delete a milestone from a project."
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The milestone's ID."
    end
    delete ":id" do
      benchmark_destroy_permissions(params[:id])
      @benchmark.user_notifier = current_user
      @benchmark.destroy
      status 204
    end

  end
end
