class Notification < ActiveRecord::Base
  belongs_to :actor, :class_name => "User", :foreign_key => "actor_id"
  belongs_to :notify, :class_name => "User", :foreign_key => "notify_id"
  belongs_to :notifier, polymorphic: true, dependent: :delete

  validates :actor, :notify, :notifier, :action, presence: true

  enum action: { created: 0, updated: 1, deleted: 2 }

  attr_readonly :actor, :notify, :notifier, :action

  def read?
    is_read
  end

  def unread?
    not read?
  end

  def dead?
    notifier.nil?
  end

  def self.dead
    where({ notifier: nil })
  end

  def message
    m = I18n.t "notification.#{notifier.class}.#{action}"
    if m.start_with? "translation missing: en.notification."
      "#{action} a #{notifier.class}"
    else
      m
    end
  end

  def is_notifier(user)
    user.class == User && user == notify
  end

  def self_link
    "/api/v1/notifications/#{id}"
  end

  def notifier_link
    notifier.self_link unless notifier.nil?
  end
end
