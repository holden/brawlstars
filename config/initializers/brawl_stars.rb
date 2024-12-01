BRAWL_STARS_API_TOKEN = ENV['BRAWL_STARS_API_TOKEN'] || Rails.application.credentials.dig(:brawl_stars_api_token)

if BRAWL_STARS_API_TOKEN.blank?
  raise 'Brawl Stars API token is not configured. Set BRAWL_STARS_API_TOKEN or add it to credentials.'
end

# Configure update interval
PLAYER_UPDATE_INTERVAL = 24.hours 