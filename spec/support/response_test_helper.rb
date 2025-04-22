# frozen_string_literal: true

module ResponseTestHelper
  # Helper method to create a mock response for testing serializers
  def create_mock_response(attributes = {})
    survey = attributes[:survey] || create(:survey)
    question = attributes[:question] || create(:question)
    
    # Set default values based on question type
    case question&.response_type
    when 'numeric_scale'
      numeric_value = attributes[:numeric_value] || 5
      text_value = nil
    when 'text', 'multiple_choice'
      numeric_value = nil
      text_value = attributes[:text_value] || 'Test response'
    when 'yes_no'
      numeric_value = nil
      text_value = attributes[:text_value] || 'Yes'
    else
      numeric_value = attributes[:numeric_value]
      text_value = attributes[:text_value]
    end
    
    # Create a mock response object that behaves like a real response
    response = double('Response')
    
    # Define the methods that will be called by the serializer
    allow(response).to receive(:id).and_return(attributes[:id] || 1)
    allow(response).to receive(:survey).and_return(survey)
    allow(response).to receive(:survey_id).and_return(survey.id)
    allow(response).to receive(:question).and_return(question)
    allow(response).to receive(:question_id).and_return(question&.id)
    allow(response).to receive(:text_value).and_return(text_value)
    allow(response).to receive(:numeric_value).and_return(numeric_value)
    allow(response).to receive(:created_at).and_return(Time.current)
    allow(response).to receive(:updated_at).and_return(Time.current)
    
    response
  end
  
  # Helper method to create a mock survey response with responses
  def create_mock_survey_with_responses(attributes = {})
    patient = attributes[:patient] || create(:patient)
    survey = attributes[:survey] || create(:survey, patient: patient)
    
    # Create mock responses if needed
    if attributes[:responses].blank? && attributes[:response_count].to_i > 0
      responses = []
      attributes[:response_count].times do |i|
        question = create(:question, content: "Question #{i + 1}", response_type: 'numeric_scale')
        responses << create_mock_response(survey: survey, question: question, numeric_value: i + 1)
      end
    else
      responses = attributes[:responses] || []
    end
    
    # Add responses to the survey
    allow(survey).to receive(:responses).and_return(responses)
    allow(survey).to receive(:patient).and_return(patient)
    
    survey
  end
end

RSpec.configure do |config|
  config.include ResponseTestHelper
end
