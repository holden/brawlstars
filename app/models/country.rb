class Country
  include ActiveModel::Model
  
  attr_accessor :name, :alpha2, :emoji_flag

  PRIORITY_COUNTRIES = %w[ZA YE XK VN] # Add any priority countries here

  class << self
    def all
      ISO3166::Country.all.map do |country|
        new(
          name: country.iso_short_name,
          alpha2: country.alpha2,
          emoji_flag: country.emoji_flag
        )
      end
    end

    def find(alpha2)
      country = ISO3166::Country.new(alpha2)
      return nil unless country

      new(
        name: country.iso_short_name,
        alpha2: country.alpha2,
        emoji_flag: country.emoji_flag
      )
    end

    def codes
      ISO3166::Country.all.map(&:alpha2)
    end

    def options_for_select
      all.map { |country| [country.name_with_flag, country.alpha2] }
    end

    def fetch_all_top_players
      # Process countries from A to Z
      codes.sort.each_with_index do |code, index|
        Rails.logger.info "Scheduling fetch for country #{code} (#{index + 1}/#{codes.length})"
        # Add a 2-second delay between each country to avoid rate limits
        FetchTopPlayersJob.set(wait: index * 2.seconds).perform_later(code)
      end
    end
  end

  def name_with_flag
    "#{emoji_flag} #{name}"
  end

  def fetch_top_players
    Rails.logger.info "Fetching top players for #{name} (#{alpha2})"
    FetchTopPlayersJob.perform_later(alpha2)
  end
end 