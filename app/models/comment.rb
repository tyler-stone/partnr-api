class Comment < Notifier
  belongs_to :user
  belongs_to :project

  validates :content, :user, :project, presence: true

  attr_readonly :user, :project

  def has_put_permissions(user)
    user.class == User && self.user.id == user.id
  end

  def has_destroy_permissions(user)
    user.class == User &&
      (
        has_put_permissions(user) ||
        self.project.has_admin_permissions(user)
      )
  end

  def followers
    project.followers
  end

  def self_link
    "/api/v1/comments/#{id}"
  end
end
