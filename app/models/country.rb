class Country
  include ActiveModel::Model
  
  attr_accessor :name, :alpha2, :emoji_flag

  class << self
    def all
      ISO3166::Country.all.map do |country|
        new(
          name: country.common_name,
          alpha2: country.alpha2,
          emoji_flag: country.emoji_flag
        )
      end
    end

    def find(alpha2)
      country = ISO3166::Country.new(alpha2)
      return nil unless country

      new(
        name: country.common_name,
        alpha2: country.alpha2,
        emoji_flag: country.emoji_flag
      )
    end

    def find_by(attributes)
      code = attributes[:code]
      return nil unless code

      find(code)
    end

    def codes
      ISO3166::Country.all.map(&:alpha2)
    end

    def options_for_select
      all.map { |country| [country.name_with_flag, country.alpha2] }
    end

    def fetch_all_top_players
      codes.each do |code|
        FetchTopPlayersJob.perform_later(code)
      end
    end
  end

  def name_with_flag
    "#{emoji_flag} #{name}"
  end

  def fetch_top_players
    FetchTopPlayersJob.perform_later(alpha2)
  end
end 