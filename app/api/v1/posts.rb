require_relative './validators/valid_user'
require_relative './validators/valid_pagination'
require_relative './validators/length'

module V1
  class Posts < Grape::API
    helpers do
      def post_put_permissions(id)
        authenticated_user
        @post ||= get_record(Post, id)
        error!("401 Unauthorized", 401) unless @post.has_put_permissions current_user
      end

      def post_destroy_permissions(id)
        authenticated_user
        @post ||= get_record(Post, id)
        error!("401 Unauthorized", 401) unless @post.has_destroy_permissions current_user
      end

      def post_create_permissions(proj_id)
        authenticated_user
        @proj ||= get_record(Project, proj_id)
        error!("401 Unauthorized", 401) unless @proj.has_create_post_permissions current_user
      end
    end

    desc "Search from all posts.", entity: Entities::PostData::AsSearch
    params do
      optional :benchmark, type: Integer, allow_blank: false, desc: "The benchmark id to which the post was posted."
      optional :user, type: Integer, allow_blank: false, desc: "The author's User ID for the posts to retrieve."
      optional :title, type: String, desc: "The title of the post to retrieve."
      optional :per_page, type: Integer, default: 25, valid_per_page: [1, 100], allow_blank: false, desc: "The number of posts per page."
      optional :page, type: Integer, default: 1, allow_blank: false, desc: "The page number of the posts."
    end
    get do
      if params.has_key? :title
        like_hash = { :title => "%#{params[:title]}%"}
        params.delete :title
      else
        like_hash = { :title => "%%" }
      end

      if params[:benchmark]
        params[:bmark] = params[:benchmark]
        params.delete :benchmark
      end

      present Post.where(permitted_params params).where("posts.title LIKE :title", like_hash)
        .page(params[:page])
        .per(params[:per_page]), with: Entities::PostData::AsSearch
    end


    desc "Get a single post based on its ID.", entity: Entities::PostData::AsFull
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The post ID."
    end
    get ":id" do
      post = get_record(Post, params[:id])
      present post, with: Entities::PostData::AsFull
    end


    desc "Create a new post for a benchmark in a project.", entity: Entities::PostData::AsFull
    params do
      requires :title, type: String, length: 1000, allow_blank: false, desc: "The post title."
      requires :content, type: String, length: 1000, allow_blank: false, desc: "The post content."
      requires :benchmark, type: Integer, allow_blank: false, desc: "The benchmark to which the post will belong."
    end
    post do
      authenticated_user
      benchmark = get_record(Bmark, params[:benchmark])
      post_create_permissions(benchmark.project_id)
      p = Post.new
      p.user_notifier = current_user
      p.update!({
        title: params[:title],
        content: params[:content],
        bmark: benchmark,
        user: current_user
      })
      present p, with: Entities::PostData::AsFull
    end


    desc "Update a specific post in a benchmark.", entity: Entities::PostData::AsFull
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The post ID."
      optional :title, type: String, length: 1000, allow_blank: false, desc: "The post title."
      optional :content, type: String, length: 1000, allow_blank: false, desc: "The content of the post."
      at_least_one_of :title, :content
    end
    put ":id" do
      post_put_permissions(params[:id])
      @post.user_notifier = current_user
      @post.update!({
        title: params[:title] || @post.title,
        content: params[:content] || @post.content
      })
      present @post, with: Entities::PostData::AsFull
    end


    desc "Delete a post on a benchmark."
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The post ID."
    end
    delete ":id" do
      post_destroy_permissions(params[:id])
      @post.user_notifier = current_user
      @post.destroy
      status 204
    end

  end
end
