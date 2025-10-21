class CreateTransitions < ActiveRecord::Migration[7.2]
  def change
    create_table :transitions do |t|
      t.references :from, null: false, foreign_key: true
      t.references :to, null: false, foreign_key: true
      t.string :trigger

      t.timestamps
    end
  end
end
