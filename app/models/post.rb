class Post < Notifier
  belongs_to :user
  belongs_to :bmark

  validates :title, :content, :user, presence: true

  def has_destroy_permissions(user)
    user.class == User &&
      (
        user == self.user ||
        self.bmark.project.has_admin_permissions(user)
      )
  end

  def has_put_permissions(user)
    # for now, anybody who can delete should be
    # able to update the post as well
    has_destroy_permissions user
  end

  def followers
    bmark.followers
  end

  def self_link
    "/api/v1/posts/#{id}"
  end
end
