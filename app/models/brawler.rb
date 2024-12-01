class Brawler < ApplicationRecord
  validates :brawl_stars_id, presence: true, uniqueness: true
  validates :name, presence: true

  has_many :player_brawlers, foreign_key: :brawler_id, primary_key: :brawl_stars_id
  has_many :players, through: :player_brawlers
  has_many :team_players
  has_many :teams, through: :team_players

  def self.sync_from_api
    response = BrawlStarsService.new.get_brawlers
    return unless response.is_a?(Array)

    response.each do |brawler_data|
      brawler = find_or_initialize_by(brawl_stars_id: brawler_data['id'])
      
      brawler.update!(
        name: brawler_data['name'],
        rarity: brawler_data.dig('rarity', 'name'),
        brawler_class: brawler_data.dig('class', 'name')
      )
    end
  end

  def fetch_details
    BrawlStarsService.new.get_brawler(brawl_stars_id)
  end
end 