class Team < ApplicationRecord
  belongs_to :battle
  has_many :team_players, dependent: :destroy
  has_many :players, through: :team_players
  has_many :brawlers, through: :team_players

  validates :battle, presence: true
  validates :rank, presence: true
  validates :result, presence: true
  
  scope :winners, -> { where(result: :victory) }
  scope :ranked, -> { order(:rank) }

  enum :result, { 
    draw: 0,
    victory: 1,
    defeat: -1
  }, validate: true
end 