class AddTriggerToEdges < ActiveRecord::Migration[7.2]
  def change
    add_column :edges, :trigger, :string
  end
end
