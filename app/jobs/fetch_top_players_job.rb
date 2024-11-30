class FetchTopPlayersJob < ApplicationJob
  queue_as :default
  
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(country_code)
    Rails.logger.info "Starting fetch for country #{country_code}"
    response = BrawlStarsService.new.get_top_players_by_country(country_code)
    
    return unless response.success?

    total_players = response.parsed_response['items'].length
    Rails.logger.info "Found #{total_players} players for country #{country_code}"

    # Reset rankings for this country
    Player.where(country_id: country_code).update_all(current_rank: nil)

    response.parsed_response['items'].each_with_index do |player_data, index|
      begin
        player_data['country_id'] = country_code
        player_data['rank'] = index + 1
        
        Rails.logger.info "Processing player #{index + 1}/#{total_players} for #{country_code}: #{player_data['name']}"
        
        player = Player.find_by(tag: player_data['tag'])
        is_new_player = player.nil?
        needs_details_update = is_new_player || player.updated_at < 24.hours.ago
        
        # Always update rank and trophies from rankings
        player = Player.create_or_update_from_api(player_data)
        
        if needs_details_update
          Rails.logger.info "#{is_new_player ? 'New player' : 'Stale data'} - fetching details for #{player.name}"
          FetchPlayerDetailsJob.set(wait: rand(1..5).seconds).perform_later(player.tag)
        else
          Rails.logger.info "Skipping details update for #{player.name} - data is fresh"
        end
      rescue => e
        Rails.logger.error "Error processing player #{player_data['name']} for #{country_code}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        next
      end
    end

    Rails.logger.info "Completed fetch for country #{country_code}"
  rescue => e
    Rails.logger.error "Error fetching top players for #{country_code}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
end 