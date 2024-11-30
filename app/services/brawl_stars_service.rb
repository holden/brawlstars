class BrawlStarsService
  include HTTParty
  base_uri 'https://api.brawlstars.com/v1'

  class RateLimitExceeded < StandardError; end

  def initialize
    token = Rails.application.credentials.brawl_stars_api_token
    @options = {
      headers: {
        'Authorization' => "Bearer #{token}",
        'Accept' => 'application/json'
      }
    }
  end

  def get_battle_log(player_tag)
    formatted_tag = player_tag.gsub('#', '').strip
    Rails.logger.info "Fetching battle log for player #{formatted_tag}"
    
    response = self.class.get("/players/%23#{formatted_tag}/battlelog", @options)
    Rails.logger.info "Battle log API response code: #{response.code}"
    Rails.logger.info "Battle log API response body: #{response.body[0..1000]}"
    
    parsed_response = handle_response(response)
    Rails.logger.info "Parsed battle log items count: #{parsed_response['items']&.length || 0}"
    
    parsed_response
  end

  def get_brawlers
    response = self.class.get("/brawlers", @options)
    
    handle_response(response)
  end

  def get_brawler(brawler_id)
    response = self.class.get("/brawlers/#{brawler_id}", @options)
    
    handle_response(response)
  end

  def get_top_players_by_country(country_code)
    self.class.get("/rankings/#{country_code}/players", @options)
  end

  def get_player(player_tag)
    formatted_tag = player_tag.gsub('#', '').strip
    response = self.class.get("/players/%23#{formatted_tag}", @options)
    
    handle_response(response)
  end

  private

  def handle_response(response)
    case response.code
    when 429 # Too Many Requests
      raise RateLimitExceeded, "API rate limit exceeded"
    when 400..499
      raise "Client Error: #{response.code} - #{response.body}"
    when 500..599
      raise "Server Error: #{response.code} - #{response.body}"
    end

    response.parsed_response # Return the parsed JSON instead of raw response
  end
end 