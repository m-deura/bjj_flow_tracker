class AddConstraintsToNodes < ActiveRecord::Migration[7.2]
  def change
    change_column_null :nodes, :chart_id, false
    change_column_null :nodes, :technique_id, false
  end
end
