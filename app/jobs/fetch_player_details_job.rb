class FetchPlayerDetailsJob < ApplicationJob
  queue_as :default

  def perform(player_tag)
    return unless should_update?(player_tag)

    Rails.logger.info "Starting player details fetch for #{player_tag}"
    response = BrawlStarsService.new.get_player(player_tag)
    return unless response.success?

    player_data = response.parsed_response
    Rails.logger.info "Raw API response: #{player_data.inspect}"
    Rails.logger.info "Received player data for #{player_tag}: #{player_data.slice('name', 'tag').inspect}"
    Rails.logger.info "Brawlers count in response: #{player_data['brawlers']&.length || 0}"
    
    Player.transaction do
      player = Player.find_by!(tag: player_tag)
      
      update_player_details(player, player_data)
      
      if player_data['brawlers'].present?
        Rails.logger.info "First brawler data sample: #{player_data['brawlers'].first.inspect}"
        player_data['brawlers'].each do |brawler_data|
          Rails.logger.info "Processing brawler ID: #{brawler_data['id']}"
          player_brawler = player.player_brawlers.find_or_initialize_by(
            brawler_id: brawler_data['id']
          )
          
          if player_brawler.new_record?
            Rails.logger.info "Creating new player_brawler for brawler_id: #{brawler_data['id']}"
          else
            Rails.logger.info "Updating existing player_brawler for brawler_id: #{brawler_data['id']}"
          end

          begin
            player_brawler.update!(
              power: brawler_data['power'],
              rank: brawler_data['rank'],
              trophies: brawler_data['trophies'],
              highest_trophies: brawler_data['highestTrophies'],
              gears: brawler_data['gears'] || [],
              star_powers: brawler_data['starPowers'] || [],
              gadgets: brawler_data['gadgets'] || []
            )
            Rails.logger.info "Successfully saved player_brawler #{player_brawler.id} for brawler_id: #{brawler_data['id']}"
          rescue => e
            Rails.logger.error "Failed to save player_brawler: #{e.message}"
            Rails.logger.error e.backtrace.join("\n")
            raise e
          end
        end
      else
        Rails.logger.error "No brawlers array in player data for #{player_tag}"
      end
    end
  rescue => e
    Rails.logger.error "Error in FetchPlayerDetailsJob for #{player_tag}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end

  private

  def should_update?(player_tag)
    # Always update when called since we only call this when trophies change
    true
  end

  def update_player_details(player, data)
    Rails.logger.info "Updating details for player #{player.name} (#{player.tag})"
    player.update!(
      name: data['name'],
      club_name: data.dig('club', 'name'),
      club_tag: data.dig('club', 'tag'),
      icon_id: data.dig('icon', 'id'),
      current_trophies: data['trophies'],
      highest_trophies: data['highestTrophies'],
      exp_level: data['expLevel'],
      exp_points: data['expPoints'],
      is_qualified_from_championship: data['isQualifiedFromChampionship'],
      victories_3vs3: data['3vs3Victories'],
      solo_victories: data['soloVictories'],
      duo_victories: data['duoVictories'],
      best_robo_rumble_time: data['bestRoboRumbleTime'],
      best_time_as_big_brawler: data['bestTimeAsBigBrawler']
    )
  end

  def update_player_brawlers(player, brawlers_data)
    return unless brawlers_data.is_a?(Array)

    Rails.logger.info "Starting brawler updates for player #{player.name} (#{brawlers_data.length} brawlers)"
    
    brawlers_data.each do |brawler_data|
      begin
        player_brawler = player.player_brawlers.find_or_initialize_by(
          brawler_id: brawler_data['id']
        )

        Rails.logger.info "Processing brawler #{brawler_data['id']} for player #{player.name} (#{player_brawler.new_record? ? 'new' : 'existing'})"

        player_brawler.update!(
          power: brawler_data['power'],
          rank: brawler_data['rank'],
          trophies: brawler_data['trophies'],
          highest_trophies: brawler_data['highestTrophies'],
          gears: brawler_data['gears'] || [],
          star_powers: brawler_data['starPowers'] || [],
          gadgets: brawler_data['gadgets'] || []
        )

        Rails.logger.info "Successfully updated brawler #{brawler_data['id']} for player #{player.name}"
      rescue => e
        Rails.logger.error "Error updating brawler #{brawler_data['id']} for player #{player.name}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        raise e
      end
    end

    Rails.logger.info "Completed all brawler updates for player #{player.name}"
  end
end 