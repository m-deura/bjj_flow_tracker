class AddTypeToTechnique < ActiveRecord::Migration[7.2]
  def change
    add_column :techniques, :category, :integer
  end
end
