require 'ruby-limiter'

# Configure global rate limiter
class RateLimiter
  class << self
    def for_brawl_stars
      @brawl_stars_limiter ||= Limiter::RateQueue.new(
        rate: 5,     # Number of requests per interval
        interval: 1  # Time period in seconds
      )
    end
  end
end 