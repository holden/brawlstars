class BrawlersController < ApplicationController
  def index
    @brawlers = Brawler.all.order(:name)
  end

  def show
    @brawler = Brawler.find(params[:id])
    @brawler_details = @brawler.fetch_details
  rescue => e
    flash[:error] = "Error fetching brawler details: #{e.message}"
    redirect_to brawlers_path
  end

  def sync
    Brawler.sync_from_api
    redirect_to brawlers_path, notice: "Brawlers synchronized successfully"
  rescue => e
    redirect_to brawlers_path, alert: "Error syncing brawlers: #{e.message}"
  end
end 