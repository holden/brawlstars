class BattleLogsController < ApplicationController
  def show
    if params[:player_tag].present?
      begin
        @battle_log = BrawlStarsService.new.get_battle_log(params[:player_tag])
        @battles = @battle_log['items']
      rescue => e
        flash.now[:error] = "Error fetching battle log: #{e.message}"
      end
    end
  end
end 