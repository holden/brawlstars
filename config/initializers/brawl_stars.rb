if Rails.application.credentials.brawl_stars_api_token.blank?
  raise "Brawl Stars API token is not configured. Please add it to credentials."
end

# Configure update interval
PLAYER_UPDATE_INTERVAL = 24.hours 