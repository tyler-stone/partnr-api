require_relative './validators/valid_user'
require_relative './validators/valid_pagination'
require_relative './validators/length'

module V1
  class Connections < Grape::API
    helpers do
      def conn_put_permissions(id)
        authenticated_user
        @conn ||= get_record(Connection, id)
        error!("You can't update that connection", 401) unless @conn.has_accept_permissions current_user
      end

      def conn_put_from_user_permissions(user_id)
        authenticated_user
        cons = current_user.connections.select { |c| c.other_user(current_user).id == user_id }
        error!("You are not connected with that user", 404) if cons.empty?
        @conn = cons.first
        error!("You can't update that connection", 401) unless @conn.has_accept_permissions current_user
      end

      def conn_destroy_permissions(id)
        authenticated_user
        @conn ||= get_record(Connection, id)
        error!("You can't delete that connection", 401) unless @conn.has_destroy_permissions current_user
      end

      def conn_destroy_from_user_permissions(user_id)
        authenticated_user
        cons = current_user.connections.select { |c| c.other_user(current_user).id == user_id }
        error!("You are not connected with that user", 404) if cons.empty?
        @conn = cons.first
        error!("You can't delete that connection", 401) unless @conn.has_destroy_permissions current_user
      end
    end


    desc "Retrieve all connections for a given user or self.", entity: Entities::ConnectionData::AsSearch
    params do
      optional :user, type: Integer, allow_blank: false, desc: "The User ID to look up."
      optional :status, type: String, allow_blank: false, values: ["pending", "accepted"], desc: "The connection's status."
      optional :per_page, type: Integer, default: 25, valid_per_page: [1, 100], allow_blank: false, desc: "The number of comments per page."
      optional :page, type: Integer, default: 1, allow_blank: false
    end
    get do
      # if no ID was supplied, look up the current user
      unless params.has_key? :user
        authenticated_user
        params[:user] = current_user.id
      end

      uid = params.delete :user

      # if the user is not authenticated,
      # only allow "accepted" connections
      if !authenticated
        params[:status] = "accepted"
      elsif params[:status] == "pending"
        error!("You can't see pending connections that aren't yours", 401) unless uid == current_user.id
      end

      if params.has_key? :status
        params[:status] = { "pending" => 0, "accepted" => 1 }[params[:status]]
      end

      present Connection.where("user_id = ? OR connection_id = ?", uid, uid).where(permitted_params params)
        .page(params[:page])
        .per(params[:per_page]), with: Entities::ConnectionData::AsSearch
    end


    desc "Get the connection requests for the current user", entity: Entities::ConnectionData::AsSearch
    params do
      optional :per_page, type: Integer, default: 25, valid_per_page: [1, 100], allow_blank: false, desc: "The number of comments per page."
      optional :page, type: Integer, default: 1, allow_blank: false
    end
    get "requests" do
      authenticated_user
      present Connection.where(connection: current_user, status: 0)
        .page(params[:page])
        .per(params[:per_page]), with: Entities::ConnectionData::AsSearch
    end


    desc "Create a new connection.", entity: Entities::ConnectionData::AsFull
    params do
      requires :connection, type: Integer, allow_blank: false, desc: "The User ID to connect with."
    end
    post do
      authenticated_user
      error!("You can't connect with yourself", 400) if current_user.id == params[:connection]
      conn_user = get_record(User, params[:connection])

      # ensure a connection does not already exist
      conns = Connection.where("user_id = ? AND connection_id = ?", current_user.id, conn_user.id).to_a + Connection.where("user_id = ? AND connection_id = ?", conn_user.id, current_user.id).to_a
      error!("That connection already exists", 400) unless conns.empty?

      conn = Connection.create!({
        user: current_user,
        connection: conn_user
      })

      present conn, with: Entities::ConnectionData::AsFull
    end


    desc "Update (accept) a connection", entity: Entities::ConnectionData::AsFull
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The connection's ID."
      requires :status, type: String, allow_blank: false, values: ["pending", "accepted"], desc: "The connection's status."
    end
    put ":id" do
      conn_put_permissions params[:id]
      @conn.status = params[:status]
      @conn.save!
      # TODO: this is bad, we should only do one activity per connection acceptance
      # and have the /activities endpoint do the heavy lifting; I feel bad about this, but it's really late
      @conn.create_activity key: 'activity.connection.accepted', owner: @conn.user
      @conn.create_activity key: 'activity.connection.accepted', owner: @conn.connection
      present @conn, with: Entities::ConnectionData::AsFull
    end


    desc "Update (accept) a connection given a user id", entity: Entities::ConnectionData::AsFull
    params do
      requires :user, type: Integer, allow_blank: false, desc: "The id of the other user in the connection."
      requires :status, type: String, allow_blank: false, values: ["pending", "accepted"], desc: "The connection's status."
    end
    put do
      conn_put_from_user_permissions params[:user]
      @conn.status = params[:status]
      @conn.save!
      # TODO: this is bad, we should only do one activity per connection acceptance
      # and have the /activities endpoint do the heavy lifting; I feel bad about this, but it's really late
      @conn.create_activity key: 'activity.connection.accepted', owner: @conn.user
      @conn.create_activity key: 'activity.connection.accepted', owner: @conn.connection
      present @conn, with: Entities::ConnectionData::AsFull
    end


    desc "Delete a connection"
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The connection's ID."
    end
    delete ":id" do
      conn_destroy_permissions params[:id]
      @conn.destroy
      status 204
    end

    desc "Delete a connection from a user ID"
    params do
      requires :user, type: Integer, allow_blank: false, desc: "The id of the other user in the connection."
    end
    delete do
      conn_destroy_from_user_permissions params[:user]
      @conn.destroy
      status 204
    end
  end
end
