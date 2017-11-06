class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  validates :first_name, :last_name, presence: true

  has_many :roles, :dependent => :nullify
  has_many :comments, :dependent => :nullify
  has_many :bmarks, :dependent => :nullify
  has_many :tasks, :dependent => :nullify
  has_many :projects, through: :roles
  has_many :applications, :dependent => :destroy
  has_many :conversations, through: :user_conversations
  has_many :user_conversations, :dependent => :destroy
  has_one :profile, :dependent => :destroy
  has_one :skillset, :dependent => :destroy
  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "/img/user.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  has_many :connections, :dependent => :destroy

  before_save :ensure_authenticaion_token

  # override devise's default behavior to queue up an email instead
  # of sending it immediately
  def send_devise_notification(notification, *args)
    begin
      devise_mailer.send(notification, self, *args).deliver_later
    rescue ActiveJob::DeserializationError
      logger.warn "Could not send email to user:"
      logger.warn args
    end
  end

  def self_link
    "/api/v1/users/#{id}"
  end

  def gravatar_link
    "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.strip.downcase)}?d=404"
  end

  def avatar_link
    # paperclip isn't working too well with AWS S3
    # so we're using this small shim
    link = URI avatar.url
    link.scheme = "https"
    link.host = Rails.application.config.s3_host
    link.path = link.path.split('/')[2..100].join('/').prepend '/'
    link.to_s
  end

  # return the full name of the user
  def name
    first_name + " " + last_name
  end

  def ensure_authenticaion_token
    self.authentication_token ||= generate_authentication_token
  end

  def feed
    @feed ||= get_feed
    clean_feed
    @feed
  end

  def partners
    @partners ||= get_partners
  end

  def connected_users
    @connected_users ||= get_connected_users
  end

  def following
    @following ||= get_following
  end

  def follows
    @follows ||= get_follows
  end

  def skillscore
    skillset.calculate
  end

  def skillset
    @skillset ||= Skillset.find_or_create_by(user_id: self.id)
  end

  def tasks
    @tasks ||= Task.where user_id: self.id
  end

  def connections_with_status(status=1)
    all_connections = Connection.where("user_id = ? OR connection_id = ? ", id, id)
    all_connections.where("status = ?", status)
  end

  def connections
    Connection.where("user_id = ? OR connection_id = ?", id, id)
  end

  def connection_status(user)
    # "connect" means they are not connected, or the "user" is nil
    # "requested" means the "user" sent this user a connection request
    # "respond" means that this user sent the "user" a connection request
    # "connected" means the two users are connected
    if user == self || user.nil? || user.class != User
      return nil
    end
    cons = connections.select { |c| c.other_user(self) == user }
    if cons.empty?
      "connect"
    else
      con = cons.first
      if con.accepted?
        "connected"
      elsif con.connection == self
        "requested"
      else
        "respond"
      end
    end
  end

  def self.search(query)
    where("LOWER( users.first_name ) LIKE :query OR LOWER( users.last_name ) LIKE :query OR LOWER( users.email ) LIKE :query", { :query => query.downcase })
  end

protected

  def confirmation_required?
    false
  end

  def send_confirmation_notification?
    true
  end

private

  def get_feed
    PublicActivity::Activity.where(id: (owner_activity_query + subject_activity_query).map(&:id)).order("created_at desc")
  end

  def clean_feed
    @feed ||= get_feed
    @feed.collect { |f| f.delete if f.trackable.nil? }
  end

  def get_partners
    partners = projects.collect { |proj| proj.users }
    partners.flatten!
    partners.delete(self)
    partners.uniq
  end

  def get_connected_users
    connections_with_status(1).map { |conn| conn.other_user self } # accepted connections only
  end

  def get_following
    follows.map { |f| f.followable }
  end

  def get_follows
    # user can only currently explicitly follow a project
    # make it so this also does something with that project's "child" entities (roles, milestones, etc.)
    Follow.where({ user: self })
  end

  def owner_activity_query
    PublicActivity::Activity.where(["owner_id IN (?)", (partners + connected_users).uniq.map { |u| u.id }])
  end

  def subject_activity_query
    unless follows.empty?
      tupleArray = follows.map { |f| [f.followable_type, f.followable_id] }
      PublicActivity::Activity.where("(trackable_type, trackable_id) IN (#{(['(?)']*tupleArray.size).join(', ')})", *tupleArray)
    else
      []
    end
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
