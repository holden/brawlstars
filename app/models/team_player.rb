class TeamPlayer < ApplicationRecord
  belongs_to :team
  belongs_to :player, foreign_key: :player_tag, primary_key: :tag, optional: true
  belongs_to :brawler

  validates :player_tag, presence: true
  validates :brawler, presence: true
end 