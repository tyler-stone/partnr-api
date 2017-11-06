class Position < ActiveRecord::Base
  belongs_to :profile

  validates :title, :company, presence: true
end
