class Interest < ActiveRecord::Base
  belongs_to :profile

  validates :title, presence: true
end
