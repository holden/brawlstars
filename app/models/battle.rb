class Battle < ApplicationRecord
  has_many :teams, dependent: :destroy
  has_many :team_players, through: :teams

  validates :battle_time, :mode, presence: true
  
  scope :by_mode, ->(mode) { where(mode: mode) }
  scope :recent, -> { order(battle_time: :desc) }
  
  def self.create_from_api(data)
    Rails.logger.info "Creating battle from API data"
    
    Battle.transaction do
      # Handle unknown/siege mode
      mode = data['battle']['mode']
      mode = 'siege' if mode == 'unknown' && data.dig('event', 'map')&.include?('Siege')
      
      # Handle missing map value
      map = data.dig('event', 'map').presence || 'Unknown'
      
      battle = new(
        battle_time: data['battleTime'],
        mode: mode,
        map: map,
        battle_type: data['battle']['type'],
        duration: data['battle']['duration']
      )

      battle.save!
      
      if data['battle']['teams'].present?
        Rails.logger.info "Processing teams battle with #{data['battle']['teams'].length} teams"
        
        # Handle different battle types
        if mode == 'duoShowdown'
          battle_rank = data['battle']['rank'] # Get the actual rank from battle data
          
          data['battle']['teams'].each_with_index do |team_players, team_index|
            result = if team_index == 0 # First team is player's team
              case battle_rank
              when 1 then :victory
              when 5 then :draw
              else :defeat
              end
            else
              :defeat # Other teams always count as defeated from player perspective
            end
            
            team = battle.teams.create!(
              rank: team_index == 0 ? battle_rank : team_index + 1,
              result: result
            )
            
            team_players.each do |player_data|
              create_team_player(team, player_data, data)
            end
          end
        else
          # For other modes
          battle_result = data['battle']['result']
          
          data['battle']['teams'].each_with_index do |team_players, team_index|
            team = battle.teams.create!(
              rank: team_index + 1,
              result: if battle_result == 'victory'
                       team_index == 0 ? :victory : :defeat
                     elsif battle_result == 'defeat'
                       team_index == 0 ? :defeat : :victory
                     else
                       :draw
                     end
            )
            
            team_players.each do |player_data|
              create_team_player(team, player_data, data)
            end
          end
        end
      end

      battle
    end
  rescue => e
    Rails.logger.error "Error creating battle from API data: #{e.message}"
    Rails.logger.error "Battle data: #{data.inspect}"
    raise e
  end

  private

  def self.create_team_player(team, player_data, battle_data)
    brawler_id = player_data['brawler']['id']
    
    # Ensure brawler exists
    unless Brawler.exists?(brawl_stars_id: brawler_id)
      Rails.logger.info "Creating missing brawler #{brawler_id}"
      Brawler.create!(
        brawl_stars_id: brawler_id,
        name: player_data['brawler']['name']
      )
    end
    
    brawler = Brawler.find_by!(brawl_stars_id: brawler_id)
    
    # Safely check for star player - handle nil case
    star_player_tag = battle_data.dig('battle', 'starPlayer', 'tag')
    is_star_player = star_player_tag.present? && player_data['tag'] == star_player_tag
    
    # Handle potentially missing or negative values
    power = player_data['brawler']['power']
    power = 1 if power.nil? || power < 1 # Power should be at least 1
    
    trophies = player_data['brawler']['trophies']
    trophies = 0 if trophies.nil? || trophies < 0
    
    gears = player_data['brawler']['gears']
    gears = [] if gears.nil?
    
    team.team_players.create!(
      player_tag: player_data['tag'],
      brawler: brawler,
      is_star_player: is_star_player,
      power: power,
      trophies: trophies,
      gears: gears
    )
  end

  def self.determine_duo_result(rank)
    case rank
    when 1 then :victory
    when 5 then :draw  # Middle rank could be considered a draw
    else :defeat
    end
  end
end 