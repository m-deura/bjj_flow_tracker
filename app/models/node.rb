class Node < ApplicationRecord
  belongs_to :chart, optional: true
  belongs_to :technique, optional: true
  belongs_to :user
  has_ancestry ancestry_format: :materialized_path2
end
