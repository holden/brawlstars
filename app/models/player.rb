class Player < ApplicationRecord
  validates :tag, presence: true, uniqueness: true
  
  belongs_to :country, foreign_key: :country_id, primary_key: :alpha2, optional: true

  scope :by_country, -> { order(:country_id) }
  scope :by_rank, -> { order(:current_rank) }
  scope :by_trophies, -> { order(current_trophies: :desc) }

  has_many :player_brawlers, dependent: :destroy
  has_many :brawlers, through: :player_brawlers

  def self.create_or_update_from_api(data)
    player = find_or_initialize_by(tag: data['tag'])
    
    # Always update name and club if provided
    player.name = data['name'] if data['name'].present?
    player.club_name = data.dig('club', 'name') if data.dig('club', 'name').present?
    player.club_tag = data.dig('club', 'tag') if data.dig('club', 'tag').present?
    
    # Update current stats
    player.current_rank = data['rank']
    player.current_trophies = data['trophies'] if data['trophies'].to_i > 1
    player.country_id = data['country_id']
    
    # Update additional stats if provided
    player.icon_id = data['icon']['id'] if data['icon'].present?
    player.highest_trophies = data['highestTrophies'] if data['highestTrophies'].present?
    player.exp_level = data['expLevel'] if data['expLevel'].present?
    player.exp_points = data['expPoints'] if data['expPoints'].present?
    player.is_qualified_from_championship = data['isQualifiedFromChampionship'] if data['isQualifiedFromChampionship'].present?
    player.victories_3vs3 = data['3vs3Victories'] if data['3vs3Victories'].present?
    player.solo_victories = data['soloVictories'] if data['soloVictories'].present?
    player.duo_victories = data['duoVictories'] if data['duoVictories'].present?
    player.best_robo_rumble_time = data['bestRoboRumbleTime'] if data['bestRoboRumbleTime'].present?
    player.best_time_as_big_brawler = data['bestTimeAsBigBrawler'] if data['bestTimeAsBigBrawler'].present?
    
    player.save!
    
    Rails.logger.info "Updated player #{player.name} with trophies: #{player.current_trophies} and rank: #{player.current_rank}"
    
    player
  end

  def country
    @country ||= Country.find(country_id) if country_id
  end

  def country_name
    country&.name
  end

  def country_flag
    country&.emoji_flag
  end

  def update_brawlers_from_api(brawlers_data)
    return unless brawlers_data.is_a?(Array)

    Rails.logger.info "Updating #{brawlers_data.length} brawlers for player #{name} (#{tag})"
    
    brawlers_data.each do |brawler_data|
      player_brawler = player_brawlers.find_or_initialize_by(
        brawler_id: brawler_data['id']
      )

      Rails.logger.info "Processing brawler ID: #{brawler_data['id']}, Power: #{brawler_data['power']}"

      player_brawler.update!(
        power: brawler_data['power'],
        rank: brawler_data['rank'],
        trophies: brawler_data['trophies'],
        highest_trophies: brawler_data['highestTrophies'],
        gears: brawler_data['gears'] || [],
        star_powers: brawler_data['starPowers'] || [],
        gadgets: brawler_data['gadgets'] || []
      )
    end
  end
end 