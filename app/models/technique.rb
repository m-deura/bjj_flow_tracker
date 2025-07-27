class Technique < ApplicationRecord
  #  belongs_to :template_technique
  belongs_to :user

  validates :name, :is_submission, :mastery_level, :is_bookmarked, presence: true
  validates :name, uniquness: true
end
