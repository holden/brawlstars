class CreateModes < ActiveRecord::Migration[8.0]
  def change
    create_table :modes do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :modes, :name, unique: true
  end
end
