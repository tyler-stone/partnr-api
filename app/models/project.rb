include ActionView::Helpers::NumberHelper
require 'set'

class Project < Notifier
  include PublicActivity::Common

  belongs_to :user, :foreign_key => 'owner'
  has_many :roles, :dependent => :destroy
  has_many :bmarks, :dependent => :destroy
  has_many :applications, through: :roles
  has_many :users, through: :roles
  has_many :tasks, :dependent => :destroy
  has_many :comments, :dependent => :destroy
  has_one :conversation, :dependent => :destroy
  has_many :follows, as: :followable, :dependent => :destroy
  has_attached_file :cover_photo, styles: { medium: "300x300>", thumb: "100x100>" }
  validates_attachment_content_type :cover_photo, :content_type => /\Aimage\/.*\Z/

  after_create :make_conversation
  after_update :update_conversation
  after_save :update_conversation

  validates :title, :owner, :creator, :status, presence: true

  enum status: { not_started: 0, in_progress: 1, complete: 2 }

  attr_readonly :creator

  def has_admin_permissions(user)
    user.class == User && owner == user.id
  end

  def has_create_post_permissions(user)
    user.class == User && ( owner == user.id || belongs_to_project(user) )
  end

  def has_create_benchmark_permissions(user)
    belongs_to_project user
  end

  def has_create_task_permissions(user)
    belongs_to_project user
  end

  def has_status_permissions(user)
    has_admin_permissions user
  end

  def formatted_price
    number_to_currency(:payment_price)
  end

  def belongs_to_project(user)
    (roles.any? { |role| role.user == user }) || user.id == owner
  end

  def users_on_proj
    Set.new(users + [User.find(owner)]).to_a
  end

  def followers
    Set.new(users + (comments.map { |c| c.user }) + (applications.map { |a| a.user }) + [User.find(owner)]).to_a
  end

  def self_link
    "/api/v1/projects/#{id}"
  end

  def cover_photo_link
    # paperclip isn't working too well with AWS S3
    # so we're using this small shim
    link = URI cover_photo.url
    link.scheme = "https"
    link.host = Rails.application.config.s3_host
    link.path = link.path.split('/')[2..100].join('/').prepend '/'
    link.to_s
  end

  def update_conversation
    make_conversation
    self.conversation.users = Set.new(self.users + [User.find(owner)]).to_a
    self.conversation.save!
  end

  def self.search(query)
    where("LOWER( projects.title ) LIKE :query", { :query => query.downcase })
  end

  private

  def make_conversation
    if !self.conversation
      self.conversation = Conversation.new({users: users})
      self.conversation.save!
    end
  end
end

class HobbyProject < Project
end

class SchoolProject < Project
end

class WorkProject < Project
  validates :sponsor, presence: true
end

class PaidProject < WorkProject
  validates :payment_price, presence: true
end
