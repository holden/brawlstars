class FetchPlayerDetailsJob < ApplicationJob
  queue_as :default

  def perform(player_tag)
    return unless should_update?(player_tag)

    response = BrawlStarsService.new.get_player(player_tag)
    return unless response.success?

    player_data = response.parsed_response
    Rails.logger.info "Received player data for #{player_tag}: #{player_data.slice('name', 'tag').inspect}"
    Rails.logger.info "Brawlers count in response: #{player_data['brawlers']&.length || 0}"
    
    Player.transaction do
      player = Player.find_by!(tag: player_tag)
      update_player_details(player, player_data)
      
      if player_data['brawlers'].present?
        Rails.logger.info "Found #{player_data['brawlers'].length} brawlers in API response"
        update_player_brawlers(player, player_data['brawlers'])
      else
        Rails.logger.warn "No brawlers data found in API response for player #{player_tag}"
      end
    end
  rescue => e
    Rails.logger.error "Error in FetchPlayerDetailsJob for #{player_tag}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end

  private

  def should_update?(player_tag)
    player = Player.find_by(tag: player_tag)
    return true unless player # New player

    # If the record was just created (within last minute), always update
    return true if player.created_at > 1.minute.ago
    
    # Otherwise, only update if it's been more than the configured interval
    player.updated_at < PLAYER_UPDATE_INTERVAL.ago
  end

  def update_player_details(player, data)
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

    Rails.logger.info "Received #{brawlers_data.length} brawlers for player #{player.name}"
    Rails.logger.debug "Brawlers data sample: #{brawlers_data.first.inspect}" if brawlers_data.any?

    begin
      player.update_brawlers_from_api(brawlers_data)
    rescue => e
      Rails.logger.error "Error updating player brawlers: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise e # Re-raise to trigger job retry
    end
  end
end 