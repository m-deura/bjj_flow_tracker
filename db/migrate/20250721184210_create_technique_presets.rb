class CreateTechniquePresets < ActiveRecord::Migration[7.2]
  def change
    create_table :technique_presets do |t|
      t.string :name_ja, null: false
      t.string :name_en, null: false
      t.integer :category

      t.timestamps
    end
    add_index :technique_presets, :name_ja, unique: true
    add_index :technique_presets, :name_en, unique: true
  end
end
