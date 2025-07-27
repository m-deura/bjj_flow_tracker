class CreateTransitions < ActiveRecord::Migration[7.2]
  def change
    create_table :transitions do |t|
      t.references :user, foreign_key: true
      t.references :from_technique, null: false, foreign_key: { to_table: :techniques }
      t.references :to_technique, null: false, foreign_key: { to_table: :techniques }
      t.text :note

      t.timestamps
    end
  end
end
