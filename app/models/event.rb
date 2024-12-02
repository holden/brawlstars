class Event < ApplicationRecord
  belongs_to :map
  belongs_to :mode
  has_many :battles
  
  validates :brawl_stars_id, presence: true, uniqueness: true
end 