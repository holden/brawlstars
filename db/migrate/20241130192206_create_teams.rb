class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.references :battle, null: false, foreign_key: true
      t.integer :rank, null: false
      t.integer :result, null: false, default: 0

      t.timestamps
    end

    add_index :teams, [:battle_id, :rank]
  end
end
