class Node < ApplicationRecord
  belongs_to :chart, optional: true
  belongs_to :technique, optional: true
  has_ancestry
end
