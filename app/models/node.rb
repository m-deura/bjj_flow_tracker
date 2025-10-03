class Node < ApplicationRecord
  belongs_to :chart
  belongs_to :technique
  has_ancestry ancestry_format: :materialized_path2
end
