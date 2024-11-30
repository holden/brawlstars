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
    Rails.logger.debug "Making request to Brawl Stars API for tag: #{formatted_tag}"
    
    full_url = "#{self.class.base_uri}/players/%23#{formatted_tag}/battlelog"
    Rails.logger.debug "Full URL: #{full_url}"
    
    response = self.class.get("/players/%23#{formatted_tag}/battlelog", @options)
    
    handle_response(response)
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
    response = self.class.get("/rankings/#{country_code}/players", @options)
    
    handle_response(response)
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

    response
  end
end 