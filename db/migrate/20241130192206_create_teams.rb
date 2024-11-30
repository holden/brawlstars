class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.references :battle, null: false, foreign_key: true
      t.integer :rank
      t.string :result

      t.timestamps
    end

    add_index :teams, [:battle_id, :rank]
  end
end
