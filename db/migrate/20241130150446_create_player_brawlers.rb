class CreatePlayerBrawlers < ActiveRecord::Migration[8.0]
  def change
    create_table :player_brawlers do |t|
      t.references :player, foreign_key: true
      t.integer :brawler_id, null: false
      t.integer :power
      t.integer :rank
      t.integer :trophies
      t.integer :highest_trophies
      t.jsonb :gears, default: []
      t.jsonb :star_powers, default: []
      t.jsonb :gadgets, default: []

      t.timestamps
    end

    add_index :player_brawlers, [:player_id, :brawler_id], unique: true
    add_index :player_brawlers, :brawler_id
  end
end
