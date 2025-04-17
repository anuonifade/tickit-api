# frozen_string_literal: true

# Join model for questions and survey workflows
class QuestionsSurveyWorkflow < ApplicationRecord
  belongs_to :question, required: true
  belongs_to :survey_workflow, required: true
  
  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  
  # Ensure unique positions within a workflow
  validates :position, uniqueness: { scope: :survey_workflow_id }
  
  # Callbacks
  before_validation :set_default_position, on: :create
  
  private
  
  def set_default_position
    return if position.present?
    return if survey_workflow.nil?
    
    # If no position is specified, add to the end
    max_position = survey_workflow.questions_survey_workflows.maximum(:position) || 0
    self.position = max_position + 1
  end
end
