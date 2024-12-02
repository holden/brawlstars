class AddIndexForBrawlerMatchups < ActiveRecord::Migration[8.0]
  def change
    add_index :team_players, [:brawler_id, :team_id]
    add_index :teams, [:battle_id, :result]
  end
end
