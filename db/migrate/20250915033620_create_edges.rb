class CreateEdges < ActiveRecord::Migration[7.2]
  def change
    create_table :edges do |t|
      t.references :from, null: false, foreign_key: { to_table: :nodes }
      t.references :to, null: false, foreign_key: { to_table: :nodes }
      t.integer :count, null: false, default: 0
      t.integer :flow, null: false, default: 0

      t.timestamps
    end
    add_index :edges, [ :from_id, :to_id, :flow ], unique: true
  end
end
