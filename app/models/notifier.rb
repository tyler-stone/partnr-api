class Notifier < ActiveRecord::Base
  self.abstract_class = true
  after_create :create_notification
  after_update :update_notification
  before_destroy :destroy_notification
  attr_accessor :user_notifier

  def create_notification
    notify 0
  end

  def update_notification
    notify 1
  end

  def destroy_notification
    destroy_child_notifications
  end

protected

  def followers
    []
  end

private

  def notify(action)
    followers.each do |follower|
      if follower != user_notifier
        n = Notification.new
        n.notify = follower
        n.notifier = self
        n.actor = user_notifier
        n.action = action
        n.save!
      end
    end
  end

  def destroy_child_notifications
    Notification.where({ notifier: self }).delete_all
  end

end
