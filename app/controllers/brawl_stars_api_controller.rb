class BrawlStarsApiController < ApiController
  def fetch_player
    FetchPlayerDetailsJob.perform_later(params[:tag])
    head :ok
  end

  def fetch_top_players
    FetchTopPlayersJob.perform_later(params[:country_code])
    head :ok
  end

  def sync_brawlers
    Brawler.sync_from_api
    head :ok
  end
end 