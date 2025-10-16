class ChangeEdgesDefault < ActiveRecord::Migration[7.2]
  def change
    change_column_default :edges, :created_at, from: nil, to: -> { 'CURRENT_TIMESTAMP' }
    change_column_default :edges, :updated_at, from: nil, to: -> { 'CURRENT_TIMESTAMP' }
    change_column_default :edges, :flow, from: 1, to: 0
  end
end
