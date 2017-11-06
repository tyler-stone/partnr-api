class Category < ActiveRecord::Base
  # these are manually created by us (the Partnr team)
  # as such, it does not inherit from the Notifier class
  # it has a few required attributes:
  validates :title, :description, :color_hex, :icon_class, presence: true
  has_many :roles
  has_many :skills
  has_and_belongs_to_many :tasks

  def self_link
    "/api/v1/categories/#{id}"
  end
end
