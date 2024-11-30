class CreateBrawlers < ActiveRecord::Migration[8.0]
  def change
    create_table :brawlers do |t|
      t.string :name
      t.integer :brawl_stars_id, null: false
      t.string :rarity
      t.string :brawler_class

      t.timestamps
    end

    add_index :brawlers, :brawl_stars_id, unique: true
  end
end
