class CreateTechniques < ActiveRecord::Migration[7.2]
  def change
    create_table :techniques do |t|
      t.references :user, foreign_key: true
      t.references :technique_preset, foreign_key: true
      t.string :name_ja, null: false
      t.string :name_en, null: false
      t.integer :category
      t.text :note
      # t.integer :mastery_level, null: false, default: 1
      # t.boolean :is_bookmarked, null: false, default: false

      t.timestamps
    end

    add_index :techniques, [ :user_id, :name_ja ], unique: true
    add_index :techniques, [ :user_id, :name_en ], unique: true
  end
end
