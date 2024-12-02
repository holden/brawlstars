class UpdateBattlesForEvents < ActiveRecord::Migration[8.0]
  def change
    # Remove old columns
    remove_column :battles, :mode
    remove_column :battles, :map
    
    # Add event reference
    add_reference :battles, :event, null: false, foreign_key: true
    
    # Clean up old indexes if they exist
    remove_index :battles, :mode if index_exists?(:battles, :mode)
  end
end
