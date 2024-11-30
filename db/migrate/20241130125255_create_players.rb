class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.string :country_id
      t.string :tag, null: false
      t.string :name
      t.string :current_club_name
      t.integer :current_rank
      t.integer :current_trophies

      t.timestamps
    end

    add_index :players, :tag, unique: true
    add_index :players, :country_id
    add_index :players, :current_rank
    add_index :players, :current_trophies
  end
end
