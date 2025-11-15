class RemoveAncestryFromNodePreset < ActiveRecord::Migration[7.2]
  def change
    remove_column :node_presets, :ancestry, :string
  end
end
