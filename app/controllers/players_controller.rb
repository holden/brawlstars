class PlayersController < ApplicationController
  helper_method :next_sort_direction

  def index
    @players = Player.all
    
    @players = @players.where(country_id: params[:country]) if params[:country].present?

    @players = case params[:sort]
              when 'country'
                @players.order(country_id: sort_direction)
              when 'rank'
                @players.order(current_rank: sort_direction)
              when 'trophies'
                if sort_direction == 'desc'
                  @players.order(Arel.sql('CASE WHEN current_trophies IS NULL THEN 0 ELSE current_trophies END DESC'))
                else
                  @players.order(Arel.sql('CASE WHEN current_trophies IS NULL THEN 999999999 ELSE current_trophies END ASC'))
                end
              else
                # Default sorting: trophies desc with nulls last
                @players.order(Arel.sql('CASE WHEN current_trophies IS NULL THEN 0 ELSE current_trophies END DESC'))
              end

    @countries = Player.distinct.pluck(:country_id).compact.map { |code| Country.find(code) }.sort_by(&:name)
    
    @pagy, @players = pagy(@players)
  end

  def show
    @player = Player.includes(player_brawlers: :brawler)
                   .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Player not found"
    redirect_to players_path
  end

  def sync
    @player = Player.find(params[:id])
    FetchPlayerDetailsJob.perform_later(@player.tag)
    
    respond_to do |format|
      format.html { redirect_to @player, notice: 'Player sync has been queued' }
      format.turbo_stream do
        # Wait a moment for the job to complete
        sleep 2
        # Reload the player to get fresh data
        @player.reload
        render turbo_stream: turbo_stream.replace(
          "player_data", 
          partial: "players/player_data", 
          locals: { player: @player }
        )
      end
    end
  end

  def sync_country
    country_code = params[:country]
    Rails.logger.info "Attempting to sync country: #{country_code}"
    
    if country_code.present?
      country = Country.find(country_code)
      if country
        Rails.logger.info "Found country: #{country.name}, starting sync"
        FetchTopPlayersJob.perform_later(country_code)  # Direct job call instead of using fetch_top_players
        flash[:notice] = "Sync started for #{country.name}"
      else
        Rails.logger.error "Country not found for code: #{country_code}"
        flash[:error] = "Country not found"
      end
    else
      Rails.logger.error "No country code provided"
      flash[:error] = "No country selected"
    end
    
    redirect_to players_path(country: country_code)
  end

  private

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
  end

  def next_sort_direction(field)
    return 'asc' unless params[:sort] == field
    params[:direction] == 'asc' ? 'desc' : 'asc'
  end
end 