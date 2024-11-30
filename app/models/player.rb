class Player < ApplicationRecord
  validates :tag, presence: true, uniqueness: true
  
  belongs_to :country, foreign_key: :country_id, primary_key: :alpha2, optional: true

  scope :by_country, -> { order(:country_id) }
  scope :by_rank, -> { order(:current_rank) }
  scope :by_trophies, -> { 
    order(Arel.sql('CASE WHEN current_trophies IS NULL THEN 0 ELSE current_trophies END DESC'))
  }

  has_many :player_brawlers, dependent: :destroy
  has_many :brawlers, through: :player_brawlers

  has_many :team_players, foreign_key: :player_tag, primary_key: :tag
  has_many :teams, through: :team_players
  has_many :battles, through: :teams

  def self.create_or_update_from_api(data)
    player = find_or_initialize_by(tag: data['tag'])
    
    # Store existing values that we want to preserve
    existing_country_id = player.country_id
    existing_rank = player.current_rank
    
    # Update with new data
    player.update!(
      name: data['name'],
      current_trophies: data['trophies'],
      highest_trophies: data['highestTrophies'],
      exp_level: data['expLevel'],
      exp_points: data['expPoints'],
      is_qualified_from_championship: data['isQualifiedFromChampionshipChallenge'],
      victories_3vs3: data['3vs3Victories'],
      solo_victories: data['soloVictories'],
      duo_victories: data['duoVictories'],
      best_robo_rumble_time: data['bestRoboRumbleTime'],
      best_time_as_big_brawler: data['bestTimeAsBigBrawler'],
      # Only update these if they're provided in the data
      country_id: data['country_id'] || existing_country_id,
      current_rank: data['rank'] || existing_rank
    )

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