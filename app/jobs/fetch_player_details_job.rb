class FetchPlayerDetailsJob < ApplicationJob
  queue_as :default

  def perform(player_tag)
    Rails.logger.info "Fetching details for player: #{player_tag}"
    
    ActiveRecord::Base.transaction do
      service = BrawlStarsService.new
      
      # Update player details
      player_data = service.get_player(player_tag)
      player = Player.create_or_update_from_api(player_data)
      
      # Update brawlers
      if player_data['brawlers'].present?
        player.update_brawlers_from_api(player_data['brawlers'])
      end
      
      # Update battle log
      update_battle_log(player_tag)
    end
  rescue => e
    Rails.logger.error "Error fetching player details for #{player_tag}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
  
  private
  
  def update_battle_log(player_tag)
    service = BrawlStarsService.new
    response = service.get_battle_log(player_tag)
    
    Rails.logger.info "Battle log response type: #{response.class}"
    Rails.logger.info "Battle log response keys: #{response.keys}" if response.is_a?(Hash)
    
    battles = response['items'] # The API returns battles in an 'items' array
    if battles.blank?
      Rails.logger.warn "No battles found in response for player #{player_tag}"
      return
    end
    
    Rails.logger.info "Processing #{battles.length} battles for player #{player_tag}"
    
    battles.each_with_index do |battle_data, index|
      Rails.logger.info "Processing battle #{index + 1}/#{battles.length}"
      Rails.logger.info "Battle data keys: #{battle_data.keys}"
      Rails.logger.info "Battle mode: #{battle_data.dig('battle', 'mode')}"
      Rails.logger.info "Has teams? #{battle_data.dig('battle', 'teams').present?}"
      
      next unless battle_data['battle']['mode'].present? && battle_data['battle']['teams'].present?
      
      Rails.logger.info "Processing battle: #{battle_data['battleTime']}"
      Rails.logger.info "Battle type: #{battle_data['battle']['type']}"
      Rails.logger.info "Battle mode: #{battle_data['battle']['mode']}"
      Rails.logger.info "Teams count: #{battle_data['battle']['teams'].length}"
      
      begin
        battle = Battle.create_from_api(battle_data)
        Rails.logger.info "Successfully created battle #{battle.id}"
      rescue => e
        Rails.logger.error "Failed to create battle: #{e.message}"
        Rails.logger.error "Full battle data: #{battle_data.inspect}"
        Rails.logger.error e.backtrace.join("\n")
        next
      end
    end
  end
end 