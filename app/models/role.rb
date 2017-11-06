class Role < Notifier
  include PublicActivity::Common

  has_many :applications, :dependent => :destroy
  belongs_to :project
  belongs_to :user
  belongs_to :category
  validates :title, :project, presence: true

  attr_readonly :project

  def has_put_permissions(user)
    user.class == User && ( self.user == user ||
      self.project.has_admin_permissions(user))
  end

  def has_destroy_permissions(user)
    user.class == User &&
      self.project.has_admin_permissions(user)
  end

  def followers
    project.followers
  end

  def self_link
    "/api/v1/roles/#{id}"
  end

  def self.search(query)
    where("LOWER( roles.title ) LIKE :query", { :query => query.downcase })
  end
end
