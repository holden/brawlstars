class CreateTeamPlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :team_players do |t|
      t.references :team, null: false, foreign_key: true
      t.references :player, foreign_key: true
      t.string :player_tag, null: false
      t.references :brawler, null: false, foreign_key: true
      t.boolean :is_star_player, default: false

      t.timestamps
    end

    add_index :team_players, :player_tag
    add_index :team_players, [:team_id, :player_tag]
  end
end
