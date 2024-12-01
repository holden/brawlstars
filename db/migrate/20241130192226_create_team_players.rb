class CreateTeamPlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :team_players do |t|
      t.references :team, null: false, foreign_key: true
      t.references :player, foreign_key: true
      t.string :player_tag, null: false
      t.references :brawler, null: false, foreign_key: true
      t.boolean :is_star_player, null: false, default: false
      t.integer :power, null: false, default: 1
      t.integer :trophies, null: false, default: 0
      t.jsonb :gears, null: false, default: []

      t.timestamps
    end

    add_index :team_players, :player_tag
  end
end
