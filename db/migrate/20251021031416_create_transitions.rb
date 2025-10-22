class CreateTransitions < ActiveRecord::Migration[7.2]
  def change
    create_table :transitions do |t|
      t.references :from, null: false, foreign_key: true, foreign_key: { to_table: :techniques }
      t.references :to, null: false, foreign_key: true, foreign_key: { to_table: :techniques }
      t.string :trigger

      t.timestamps
    end
    add_index :transitions, [ :from_id, :to_id ], unique: true
  end
end
