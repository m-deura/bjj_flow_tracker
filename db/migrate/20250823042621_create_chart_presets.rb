class CreateChartPresets < ActiveRecord::Migration[7.2]
  def change
    create_table :chart_presets do |t|
      t.string :name

      t.timestamps
    end
  end
end
