class Map < ApplicationRecord
  has_many :events
  has_many :modes, through: :events
  has_many :battles, through: :events
  
  validates :name, presence: true, uniqueness: true
end 