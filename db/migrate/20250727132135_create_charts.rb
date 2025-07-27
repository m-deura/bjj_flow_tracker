class CreateCharts < ActiveRecord::Migration[7.2]
  def change
    create_table :charts do |t|
      t.references :user, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end
    add_index :charts, :name, unique: true
  end
end
