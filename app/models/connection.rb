class Connection < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :user
  belongs_to :connection, :class_name => "User"

  enum status: { pending: 0, accepted: 1 }

  def has_destroy_permissions(usr)
    usr.class == User &&
    (
      user.id == usr.id ||
      connection.id == usr.id
    )
  end

  def has_accept_permissions(usr)
    usr.class == User && usr.id == connection.id
  end

  def self_link
    "/api/v1/connections/#{id}"
  end

  def other_user(usr)
    usr == user ? connection : user
  end
end
