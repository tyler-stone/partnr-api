require_relative './validators/valid_user'
require_relative './validators/valid_pagination'
require_relative './validators/length'

module V1
  class Notifications < Grape::API
    helpers do
      def notification_update_permissions(id)
        authenticated_user
        @notification ||= get_record(Notification, id)
        error!("401 Unauthorized", 401) unless @notification.is_notifier(current_user)
      end
    end

    desc "Retrieve notifications for a user.", entity: Entities::NotificationData
    params do
      optional :per_page, type: Integer, default: 25, valid_per_page: [1, 100], allow_blank: false, desc: "The number of notifications per page."
      optional :page, type: Integer, default: 1, allow_blank: false, desc: "The page number of the notifications."
      optional :read, type: Boolean, allow_blank: false, desc: "Only return notifications that are either 'read' or 'unread'."
    end
    get do
      conditions = { :notify => current_user }
      if params.member? :read
        conditions[:is_read] = params[:read]
      end
      present Notification.where(conditions)
        .order(id: :desc)
        .page(params[:page])
        .per(params[:per_page]), with: Entities::NotificationData
    end

    desc "Update a notification.", entity: Entities::NotificationData
    params do
      requires :id, type: Integer, allow_blank: false, desc: "The ID of the notification to update."
      requires :read, type: Boolean, allow_blank: false, desc: "The is_read status to update the notification to."
    end
    put ":id" do
      notification_update_permissions params[:id]
      @notification.is_read = params[:read]
      @notification.save!
      present @notification, with: Entities::NotificationData
    end
  end
end
