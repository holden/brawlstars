class AddDetailsToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :icon_id, :integer
    add_column :players, :highest_trophies, :integer
    add_column :players, :exp_level, :integer
    add_column :players, :exp_points, :integer
    add_column :players, :is_qualified_from_championship, :boolean, default: false
    add_column :players, :victories_3vs3, :integer
    add_column :players, :solo_victories, :integer
    add_column :players, :duo_victories, :integer
    add_column :players, :best_robo_rumble_time, :integer
    add_column :players, :best_time_as_big_brawler, :integer
    add_column :players, :club_tag, :string
    
    # Rename current_club_name to club_name
    rename_column :players, :current_club_name, :club_name
  end
end 