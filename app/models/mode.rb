class Mode < ApplicationRecord
  has_many :events
  has_many :maps, through: :events
  has_many :battles, through: :events
  
  validates :name, presence: true, uniqueness: true
end 