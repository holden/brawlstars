class CreateBattles < ActiveRecord::Migration[8.0]
  def change
    create_table :battles do |t|
      t.string :battle_time, null: false
      t.string :mode, null: false
      t.string :map
      t.string :battle_type
      t.integer :duration

      t.timestamps
    end

    add_index :battles, :battle_time
    add_index :battles, :mode
  end
end
