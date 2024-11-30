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

  private

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
  end

  def next_sort_direction(field)
    return 'asc' unless params[:sort] == field
    params[:direction] == 'asc' ? 'desc' : 'asc'
  end
end 