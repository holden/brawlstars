class CreateBattles < ActiveRecord::Migration[7.0]
  def change
    create_table :battles do |t|
      t.string :battle_time, null: false
      t.string :mode, null: false
      t.string :map, null: false, default: 'Unknown'
      t.string :battle_type
      t.integer :duration

      t.timestamps
    end

    add_index :battles, :battle_time
    add_index :battles, :mode
  end
end
