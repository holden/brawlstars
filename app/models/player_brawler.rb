class PlayerBrawler < ApplicationRecord
  belongs_to :player
  belongs_to :brawler, foreign_key: :brawler_id, primary_key: :brawl_stars_id

  validates :brawler_id, presence: true
  validates :brawler_id, uniqueness: { scope: :player_id }
end 