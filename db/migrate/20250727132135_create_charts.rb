class CreateCharts < ActiveRecord::Migration[7.2]
  def change
    create_table :charts do |t|
      t.references :user, foreign_key: true, null: false
      t.references :chart_preset, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end
    add_index :charts, [ :user_id, :name ], unique: true
  end
end
