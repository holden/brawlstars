class FetchTopPlayersJob < ApplicationJob
  queue_as :default

  def perform(country_code)
    response = BrawlStarsService.new.get_top_players_by_country(country_code)
    
    return unless response.success?

    response.parsed_response['items'].each_with_index do |player_data, index|
      player_data['country_id'] = country_code
      player_data['rank'] = index + 1
      
      Rails.logger.info "Processing player: #{player_data['name']} with rank: #{player_data['rank']}"
      
      player = Player.create_or_update_from_api(player_data)
      
      # Only fetch details if player hasn't been updated recently
      if needs_update?(player)
        FetchPlayerDetailsJob.perform_later(player.tag)
        Rails.logger.info "Enqueued details job for player #{player.name} (#{player.tag})"
      else
        Rails.logger.info "Skipping details update for #{player.name} - last updated #{player.updated_at}"
      end
    end
  rescue => e
    Rails.logger.error "Error fetching top players for #{country_code}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  private

  def needs_update?(player)
    return true if player.new_record?
    player.updated_at < PLAYER_UPDATE_INTERVAL.ago
  end
end 