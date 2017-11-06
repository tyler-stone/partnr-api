class Location < ActiveRecord::Base
  belongs_to :profile
  acts_as_mappable

  validates :geo_string, presence: true
end
