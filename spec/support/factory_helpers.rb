# frozen_string_literal: true

# Helper module for working with factories in tests
module FactoryHelpers
  # Create a survey with responses
  def create_survey_with_responses(response_count = 3)
    survey = create(:survey)
    response_count.times do |i|
      create(:response, survey: survey, position: i + 1)
    end
    survey
  end
  
  # Create a workflow with questions
  def create_workflow_with_questions(question_count = 3)
    workflow = create(:survey_workflow)
    questions = []
    
    question_count.times do |i|
      question = create(:question)
      create(:questions_survey_workflow, survey_workflow: workflow, question: question, position: i + 1)
      questions << question
    end
    
    [workflow, questions]
  end
  
  # Create a patient with surveys
  def create_patient_with_surveys(survey_count = 2)
    patient = create(:patient)
    surveys = create_list(:survey, survey_count, patient: patient)
    [patient, surveys]
  end
end

RSpec.configure do |config|
  config.include FactoryHelpers
end
