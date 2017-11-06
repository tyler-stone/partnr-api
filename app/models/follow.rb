class Follow < ActiveRecord::Base
  belongs_to :user

  def self.project(proj)
    where(followable_type: "Project", followable_id: proj.id)
  end
end
