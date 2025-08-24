class CreateChartPresets < ActiveRecord::Migration[7.2]
  def change
    create_table :chart_presets do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :chart_presets, :name, unique: true
  end
end
