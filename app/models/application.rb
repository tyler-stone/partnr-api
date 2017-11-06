class Application < Notifier
  belongs_to :user
  belongs_to :role
  belongs_to :project

  validate :project_and_role_align
  validates :status, :role, :project, :user, presence: true

  before_update :destroy_notification, if: :status_rejected?
  before_update :update_role, if: :status_accepted?
  skip_callback :update, :after, :update_notification

  enum status: { pending: 0, accepted: 1, rejected: 2 }

  def has_update_permissions(user)
    user.class == User && self.user.id == user.id
  end

  def has_destroy_permissions(user)
    user.class == User &&
      (
        self.role.project.has_admin_permissions(user) ||
        user.id == self.user.id
      )
  end

  def has_accept_permissions(user)
    user.class == User && self.project.has_admin_permissions(user)
  end

  def project_and_role_align
    if self.project.id != self.role.project.id
      errors.add(:project, "The application and role must belong to the same project")
    end
  end

  def followers
    project.users_on_proj
  end

  def self_link
    "/api/v1/applications/#{id}"
  end

  private

  def status_accepted?
    self.changes[:status].present? && self.changes[:status][1] == 'acccepted'
  end

  def status_rejected?
    self.changes[:status].present? && self.changes[:status][1] == 'rejected'
  end
end
