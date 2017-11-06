class Skill < ActiveRecord::Base
  belongs_to :category

  validates :title, :category, presence: true

  has_and_belongs_to_many :tasks

  def self_link
    "/api/v1/skills/#{id}"
  end

  def self.search(query)
    where("LOWER( skills.title ) LIKE :query", { :query => query.downcase })
  end
end
