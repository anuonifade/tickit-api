# frozen_string_literal: true

# Survey workflow model for managing sets of questions
class SurveyWorkflow < ApplicationRecord
  # Associations
  has_many :questions_survey_workflows, dependent: :destroy
  has_many :questions, through: :questions_survey_workflows
  has_many :surveys, dependent: :restrict_with_error
  
  # Validations
  validates :name, presence: true, uniqueness: true
  
  # Callbacks
  before_destroy :ensure_no_active_surveys
  
  # Instance methods
  def ordered_questions
    questions.joins(:questions_survey_workflows)
            .order('questions_survey_workflows.position ASC')
  end
  
  # Add a question to the workflow with a specific position
  def add_question(question, position)
    questions_survey_workflows.create(
      question: question,
      position: position
    )
  end
  
  private
  
  def ensure_no_active_surveys
    # Add logic here to prevent deletion if this workflow is in use
    # This is a placeholder for future implementation
    true
  end
end
