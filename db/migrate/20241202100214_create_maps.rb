class CreateMaps < ActiveRecord::Migration[8.0]
  def change
    create_table :maps do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :maps, :name, unique: true
  end
end
