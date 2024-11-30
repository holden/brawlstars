class PlayerBrawler < ApplicationRecord
  belongs_to :player
  belongs_to :brawler, foreign_key: :brawler_id, primary_key: :brawl_stars_id

  validates :brawler_id, presence: true
  validates :brawler_id, uniqueness: { scope: :player_id }

  after_save :log_save
  after_create :log_create

  private

  def log_save
    Rails.logger.info "Saved PlayerBrawler: player_id=#{player_id}, brawler_id=#{brawler_id}"
  end

  def log_create
    Rails.logger.info "Created new PlayerBrawler: player_id=#{player_id}, brawler_id=#{brawler_id}"
  end
end 