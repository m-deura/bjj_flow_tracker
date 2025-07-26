class CreateTechniques < ActiveRecord::Migration[7.2]
  def change
    create_table :techniques do |t|
      t.references :template_technique_id, foreign_key: true
      t.references :user_id, null: false, foreign_key: true
      t.string :name, null: false
      t.text :note
      t.boolean :is_submission, null: false, default: false
      t.integer :mastery_level, null: false, default: 1
      t.boolean :is_bookmarked, null: false, default: false

      t.timestamps

      add_index :techniques, :name, unique: true
    end
  end
end
