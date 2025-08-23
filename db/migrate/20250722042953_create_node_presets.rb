class CreateNodePresets < ActiveRecord::Migration[7.2]
  def change
    create_table :node_presets do |t|
      t.references :chart_preset, null: false, foreign_key: true
      t.references :technique_preset, null: false, foreign_key: true
      t.string :name
      t.string :ancestry

      t.timestamps
    end
  end
end
