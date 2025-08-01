class CreateTechniquePresets < ActiveRecord::Migration[7.2]
  def change
    create_table :technique_presets do |t|
      t.string :name_ja
      t.string :name_en
      t.integer :category

      t.timestamps
    end
  end
end
