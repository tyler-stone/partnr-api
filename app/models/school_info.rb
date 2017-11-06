class SchoolInfo < ActiveRecord::Base
  belongs_to :profile

  validates :school_name, :grad_year, presence: true
end
