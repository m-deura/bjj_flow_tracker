class CreateNodePresets < ActiveRecord::Migration[7.2]
  def change
    create_table :node_presets do |t|
      t.references :chart_preset, null: false, foreign_key: true
      t.references :technique_preset, null: false, foreign_key: true
      t.string :ancestry, collation: 'C', null: false

      t.timestamps
    end
    add_index :node_presets, :ancestry
  end
end
