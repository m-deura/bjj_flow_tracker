class Technique < ApplicationRecord
  belongs_to :template_technique_id
  belongs_to :user_id
end
