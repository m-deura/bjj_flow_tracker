class CreateEdgePresets < ActiveRecord::Migration[7.2]
  def change
    create_table :edge_presets do |t|
      t.references :from, null: false, foreign_key: { to_table: :node_presets }
      t.references :to, null: false, foreign_key: { to_table: :node_presets }

      t.timestamps
    end
  end
end
