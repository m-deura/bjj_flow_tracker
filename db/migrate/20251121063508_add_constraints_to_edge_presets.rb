class AddConstraintsToEdgePresets < ActiveRecord::Migration[7.2]
  def change
    add_index :edge_presets, [ :from_id, :to_id ], unique: true
  end
end
