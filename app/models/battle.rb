class Battle < ApplicationRecord
  has_many :teams, dependent: :destroy
  has_many :team_players, through: :teams

  validates :battle_time, :mode, presence: true
  
  scope :by_mode, ->(mode) { where(mode: mode) }
  scope :recent, -> { order(battle_time: :desc) }
  
  def self.create_from_api(data)
    Rails.logger.info "Creating battle from API data"
    Rails.logger.info "Battle data keys: #{data.keys}"
    Rails.logger.info "Battle mode: #{data.dig('battle', 'mode')}"
    Rails.logger.info "Teams present: #{data.dig('battle', 'teams').present?}"
    
    Battle.transaction do
      battle = new(
        battle_time: data['battleTime'],
        mode: data['battle']['mode'],
        map: data.dig('event', 'map'),
        battle_type: data['battle']['type'],
        duration: data['battle']['duration']
      )

      # Validate battle data before proceeding
      unless data['battle']['teams'].present? && data['battle']['teams'].all? { |team| team.present? }
        Rails.logger.error "Invalid battle data: missing or empty teams"
        Rails.logger.error "Teams data: #{data['battle']['teams'].inspect}"
        raise "Invalid battle data: missing teams"
      end

      if battle.save
        Rails.logger.info "Created battle record with ID: #{battle.id}"
      else
        Rails.logger.error "Failed to save battle: #{battle.errors.full_messages}"
        raise ActiveRecord::RecordInvalid.new(battle)
      end
      
      if data['battle']['teams'].present?
        Rails.logger.info "Processing teams battle with #{data['battle']['teams'].length} teams"
        
        # Determine winning team based on battle result
        battle_result = data['battle']['result']
        Rails.logger.info "Battle result: #{battle_result}"
        
        # Create all teams and players atomically
        data['battle']['teams'].each_with_index do |team_players, team_index|
          # First team (index 0) wins if result is victory
          is_winner = (team_index == 0 && battle_result == 'victory') || 
                     (team_index == 1 && battle_result == 'defeat')
          
          team = battle.teams.create!(
            rank: is_winner ? 1 : 2,
            result: is_winner ? 'victory' : 'defeat'
          )
          
          # Create all players for this team
          team_players.each do |player_data|
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
            
            # Safely check for star player
            is_star_player = if data.dig('battle', 'starPlayer', 'tag').present?
                             player_data['tag'] == data['battle']['starPlayer']['tag']
                           else
                             false
                           end
            
            team.team_players.create!(
              player_tag: player_data['tag'],
              brawler: brawler,
              is_star_player: is_star_player
            )
          end
        end

        # Verify all data was created correctly
        expected_player_count = data['battle']['teams'].sum(&:length)
        actual_player_count = battle.team_players.reload.count
        
        unless expected_player_count == actual_player_count
          raise ActiveRecord::Rollback, "Battle creation failed: expected #{expected_player_count} players, got #{actual_player_count}"
        end
      end

      battle
    end
  rescue => e
    Rails.logger.error "Error creating battle from API data: #{e.message}"
    Rails.logger.error "Battle data: #{data.inspect}"
    raise e
  end
end 