# frozen_string_literal: true

# Question model for surveys
class Question < ApplicationRecord
  # Associations
  has_many :questions_survey_workflows, dependent: :destroy
  has_many :survey_workflows, through: :questions_survey_workflows
  has_many :responses, dependent: :destroy
  
  # Validations
  validates :content, presence: true
  validates :response_type, presence: true, inclusion: { 
    in: %w(text numeric_scale multiple_choice yes_no), 
    message: "%{value} is not a valid response type" 
  }
  
  # Scopes
  scope :by_response_type, ->(type) { where(response_type: type) }
  
  # Class methods
  def self.response_types
    %w(text numeric_scale multiple_choice yes_no)
  end
end
