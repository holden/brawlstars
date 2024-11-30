class Country
  include ActiveModel::Model
  
  attr_accessor :name, :alpha2, :emoji_flag

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
      countries = all
      Rails.logger.info "Starting fetch_all_top_players for #{countries.length} countries"
      
      countries.each_with_index do |country, index|
        Rails.logger.info "Queueing job #{index + 1}/#{countries.length} for #{country.name} (#{country.alpha2})"
        FetchTopPlayersJob.set(wait: index * 5.seconds).perform_later(country.alpha2)
      end
    end
  end

  def name_with_flag
    "#{emoji_flag} #{name}"
  end

  def fetch_top_players
    Rails.logger.info "Starting fetch_top_players for single country: #{name} (#{alpha2})"
    FetchTopPlayersJob.perform_later(alpha2)
  end
end 