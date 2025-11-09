class RemoveAncestryFromNode < ActiveRecord::Migration[7.2]
  def change
    remove_column :nodes, :ancestry, :string
  end
end
