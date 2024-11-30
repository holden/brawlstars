class BattlesController < ApplicationController
  def index
    @battles = Battle.includes(teams: { team_players: [:player, :brawler] })
                    .order(battle_time: :desc)
    @pagy, @battles = pagy(@battles)
  end

  def show
    @battle = Battle.includes(teams: { team_players: [:player, :brawler] })
                   .find(params[:id])
  end
end 