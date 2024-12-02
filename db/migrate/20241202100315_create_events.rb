class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.integer :brawl_stars_id, null: false
      t.references :map, null: false, foreign_key: true
      t.references :mode, null: false, foreign_key: true

      t.timestamps
    end

    add_index :events, :brawl_stars_id, unique: true
  end
end
