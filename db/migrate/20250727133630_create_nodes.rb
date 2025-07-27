class CreateNodes < ActiveRecord::Migration[7.2]
  def change
    create_table :nodes do |t|
      t.references :chart, foreign_key: true
      t.references :technique, foreign_key: true
      t.string :ancestry, collation: 'C', null: false

      t.timestamps
    end
    add_index :nodes, :ancestry
  end
end
